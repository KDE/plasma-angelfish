/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

#include "dbmanager.h"
#include "iconimageprovider.h"

#include <QDateTime>
#include <QDebug>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QVariant>
#include <QDir>

#include <exception>

constexpr int DB_USER_VERSION = 1;
constexpr int MAX_BROWSER_HISTORY_SIZE = 3000;

DBManager::DBManager(QObject *parent)
    : QObject(parent)
{
    const QString dbpath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    const QString dbname = dbpath + QStringLiteral("/angelfish.sqlite");

    if (!QDir().mkpath(dbpath)) {
        qCritical() << "Database directory does not exist and cannot be created: " << dbpath;
        throw std::runtime_error("Database directory does not exist and cannot be created: " + dbpath.toStdString());
    }

    QSqlDatabase database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
    database.setDatabaseName(dbname);
    if (!database.open()) {
        qCritical() << "Failed to open database" << dbname;
        throw std::runtime_error("Failed to open database " + dbname.toStdString());
    }

    if (!migrate()) {
        qCritical() << "Failed to initialize or migrate the schema in" << dbname;
        throw std::runtime_error("Failed to initialize or migrate the schema in " + dbname.toStdString());
    }

    trimHistory();
    trimIcons();
}

int DBManager::version()
{
    QSqlQuery query(QStringLiteral("PRAGMA user_version"));
    if (query.next()) {
        bool ok;
        int value = query.value(0).toInt(&ok);
        if (ok)
            return value;
    }
    return -1;
}

void DBManager::setVersion(int v)
{
    QSqlQuery query;
    query.prepare(QStringLiteral("PRAGMA user_version = %1").arg(v));
    query.exec();
}

bool DBManager::execute(const QString &command)
{
    QSqlQuery query;
    if (!query.exec(command)) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query.lastQuery();
        qWarning() << query.lastError();
        return false;
    }
    return true;
}

bool DBManager::execute(QSqlQuery &query)
{
    if (!query.exec()) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query.lastQuery();
        qWarning() << query.lastError();
        return false;
    }
    return true;
}

bool DBManager::migrate()
{
    for (int v = version(); v != DB_USER_VERSION; v = version()) {
        if (v < 0 || v > DB_USER_VERSION) {
            qCritical() << "Don't know what to do with the database schema version" << v << ". Bailing out.";
            return false;
        }

        if (v == 0) {
            if (!migrateTo1())
                return false;
        }
    }
    return true;
}

bool DBManager::migrateTo1()
{
    // Starting from empty database, let's create the tables.
    const QString bookmarks = QStringLiteral("CREATE TABLE bookmarks (url TEXT UNIQUE, title TEXT, icon TEXT, lastVisited INT)");
    const QString history = QStringLiteral("CREATE TABLE history (url TEXT UNIQUE, title TEXT, icon TEXT, lastVisited INT)");
    const QString icons = QStringLiteral("CREATE TABLE icons (url TEXT UNIQUE, icon BLOB)");
    const QString idx_bookmarks = QStringLiteral("CREATE UNIQUE INDEX idx_bookmarks_url ON bookmarks(url)");
    const QString idx_history = QStringLiteral("CREATE UNIQUE INDEX idx_history_url ON history(url)");
    const QString idx_icons = QStringLiteral("CREATE UNIQUE INDEX idx_icons_url ON icons(url)");
    if (!execute(bookmarks) || !execute(idx_bookmarks) || !execute(history) || !execute(idx_history) || !execute(icons) || !execute(idx_icons))
        return false;

    setVersion(1);
    qDebug() << "Migrated database schema to version 1";
    return true;
}

void DBManager::trimHistory()
{
    execute(QStringLiteral("DELETE FROM history WHERE rowid NOT IN (SELECT rowid FROM history"
                           " ORDER BY lastVisited DESC LIMIT %1)")
                .arg(MAX_BROWSER_HISTORY_SIZE));
}

void DBManager::trimIcons()
{
    execute(
        QStringLiteral("DELETE FROM icons WHERE url NOT IN "
                       "(SELECT icon FROM history UNION SELECT icon FROM bookmarks)"));
}

void DBManager::addRecord(const QString &table, const QVariantMap &pagedata)
{
    const QString url = pagedata.value(QStringLiteral("url")).toString();
    const QString title = pagedata.value(QStringLiteral("title")).toString();
    const QString icon = pagedata.value(QStringLiteral("icon")).toString();
    const qint64 lastVisited = QDateTime::currentSecsSinceEpoch();

    if (url.isEmpty() || url == QStringLiteral("about:blank"))
        return;

    QSqlQuery query;
    query.prepare(QStringLiteral("INSERT OR REPLACE INTO %1 (url, title, icon, lastVisited) "
                                 "VALUES (:url, :title, :icon, :lastVisited)")
                      .arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    query.bindValue(QStringLiteral(":title"), title);
    query.bindValue(QStringLiteral(":icon"), icon);
    query.bindValue(QStringLiteral(":lastVisited"), lastVisited);
    execute(query);

    emit databaseTableChanged(table);
}

void DBManager::removeRecord(const QString &table, const QString &url)
{
    if (url.isEmpty())
        return;

    QSqlQuery query;
    query.prepare(QStringLiteral("DELETE FROM %1 WHERE url = :url").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    execute(query);

    emit databaseTableChanged(table);
}

bool DBManager::hasRecord(const QString &table, const QString &url) const
{
    QSqlQuery query;
    query.prepare(QStringLiteral("SELECT 1 FROM %1 WHERE url = :url").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    if (!query.exec()) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query.lastQuery();
        qWarning() << query.lastError();
        return false;
    }
    while (query.next()) {
        return true;
    }
    return false;
}

void DBManager::updateIconRecord(const QString &table, const QString &url, const QString &iconSource)
{
    if (url.isEmpty())
        return;

    QSqlQuery query;
    query.prepare(QStringLiteral("UPDATE %1 SET icon = :icon WHERE url = :url").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    query.bindValue(QStringLiteral(":icon"), iconSource);
    execute(query);

    emit databaseTableChanged(table);
}

void DBManager::setLastVisitedRecord(const QString &table, const QString &url)
{
    if (url.isEmpty())
        return;

    qint64 lastVisited = QDateTime::currentSecsSinceEpoch();
    QSqlQuery query;
    query.prepare(QStringLiteral("UPDATE %1 SET lastVisited = :lv WHERE url = :url").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    query.bindValue(QStringLiteral(":lv"), lastVisited);
    execute(query);

    emit databaseTableChanged(table);
}

void DBManager::addBookmark(const QVariantMap &bookmarkdata)
{
    addRecord(QStringLiteral("bookmarks"), bookmarkdata);
}

void DBManager::removeBookmark(const QString &url)
{
    removeRecord(QStringLiteral("bookmarks"), url);
}

bool DBManager::isBookmarked(const QString &url) const
{
    return hasRecord(QStringLiteral("bookmarks"), url);
}

void DBManager::addToHistory(const QVariantMap &pagedata)
{
    addRecord(QStringLiteral("history"), pagedata);
}

void DBManager::removeFromHistory(const QString &url)
{
    removeRecord(QStringLiteral("history"), url);
}

void DBManager::updateLastVisited(const QString &url)
{
    setLastVisitedRecord(QStringLiteral("bookmarks"), url);
    setLastVisitedRecord(QStringLiteral("history"), url);
}

void DBManager::updateIcon(const QString &url, const QString &iconSource)
{
    QString updatedSource = IconImageProvider::storeImage(iconSource);
    updateIconRecord(QStringLiteral("bookmarks"), url, updatedSource);
    updateIconRecord(QStringLiteral("history"), url, updatedSource);
}
