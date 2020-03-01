/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Jonah Brüchert  <jbb@kaidan.im>                        *
 *             2020 Rinigus <rinigus.git@gmail.com>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/

#include "dbmanager.h"
#include "iconimageprovider.h"

#include <QDateTime>
#include <QDebug>
#include <QImage>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>

#include <exception>

#define DB_USER_VERSION 1
#define MAX_BROWSER_HISTORY_SIZE 3000

DBManager::DBManager(QObject *parent) : QObject(parent)
{
    QString dbname = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
            + QStringLiteral("/angelfish/angelfish.sqlite");

    QSqlDatabase database = QSqlDatabase::addDatabase(QLatin1String("QSQLITE"));
    database.setDatabaseName(dbname);
    if (!database.open()) {
        throw std::runtime_error("Failed to open database " + dbname.toStdString());
    }

    if (!migrate()) {
        throw std::runtime_error("Failed to initialize or migrate the schema in " + dbname.toStdString());
    }

    trimHistory();
    trimIcons();
}

int DBManager::version()
{
    QSqlQuery query(QLatin1String("PRAGMA user_version"));
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
    query.prepare( QStringLiteral("PRAGMA user_version = %1").arg(v) );
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
    QString bookmarks = QStringLiteral("CREATE TABLE bookmarks (url TEXT UNIQUE, title TEXT, icon TEXT, lastVisited INT)");
    QString history = QStringLiteral("CREATE TABLE history (url TEXT UNIQUE, title TEXT, icon TEXT, lastVisited INT)");
    QString icons = QStringLiteral("CREATE TABLE icons (url TEXT UNIQUE, icon BLOB)");
    QString idx_bookmarks = QStringLiteral("CREATE UNIQUE INDEX idx_bookmarks_url ON bookmarks(url)");
    QString idx_history = QStringLiteral("CREATE UNIQUE INDEX idx_history_url ON history(url)");
    QString idx_icons = QStringLiteral("CREATE UNIQUE INDEX idx_icons_url ON icons(url)");
    if (!execute(bookmarks) || !execute(idx_bookmarks) ||
            !execute(history) || !execute(idx_history) ||
            !execute(icons) || !execute(idx_icons) )
        return false;

    setVersion(1);
    qDebug() << "Migrated database schema to version 1";
    return true;
}

void DBManager::trimHistory()
{
    execute(QStringLiteral("DELETE FROM history WHERE rowid NOT IN (SELECT rowid FROM history" \
                           " ORDER BY lastVisited DESC LIMIT %1)").arg(MAX_BROWSER_HISTORY_SIZE));
}

void DBManager::trimIcons()
{
    execute(QStringLiteral("DELETE FROM icons WHERE url NOT IN " \
                           "(SELECT icon FROM history UNION SELECT icon FROM bookmarks)"));
}

void DBManager::addRecord(const QString &table, const QVariantMap &pagedata)
{
    QString url = pagedata.value("url").toString();
    QString title = pagedata.value("title").toString();
    QString icon = pagedata.value("icon").toString();
    qint64 lastVisited = QDateTime::currentSecsSinceEpoch();

    if (url.isEmpty() || url == "about:blank") return;

    QSqlQuery query;
    query.prepare(QStringLiteral("INSERT OR REPLACE INTO %1 (url, title, icon, lastVisited) " \
                                 "VALUES (:url, :title, :icon, :lastVisited)").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    query.bindValue(QStringLiteral(":title"), title);
    query.bindValue(QStringLiteral(":icon"), icon);
    query.bindValue(QStringLiteral(":lastVisited"), lastVisited);
    execute(query);

    emit databaseTableChanged(table);
}

void DBManager::removeRecord(const QString &table, const QString &url)
{
    if (url.isEmpty()) return;

    QSqlQuery query;
    query.prepare(QStringLiteral("DELETE FROM %1 WHERE url = :url").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    execute(query);

    emit databaseTableChanged(table);
}

void DBManager::updateIconRecord(const QString &table, const QString &url, const QString &iconSource)
{
    if (url.isEmpty()) return;

    QSqlQuery query;
    query.prepare(QStringLiteral("UPDATE %1 SET icon = :icon WHERE url = :url").arg(table));
    query.bindValue(QStringLiteral(":url"), url);
    query.bindValue(QStringLiteral(":icon"), iconSource);
    execute(query);

    emit databaseTableChanged(table);
}

void DBManager::lastVisitedRecord(const QString &table, const QString &url)
{
    if (url.isEmpty()) return;

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

void DBManager::addToHistory(const QVariantMap &pagedata)
{
    addRecord(QStringLiteral("history"), pagedata);
}

void DBManager::removeFromHistory(const QString &url)
{
    removeRecord(QStringLiteral("history"), url);
}

void DBManager::lastVisited(const QString &url)
{
    lastVisitedRecord(QStringLiteral("bookmarks"), url);
    lastVisitedRecord(QStringLiteral("history"), url);
}

void DBManager::updateIcon(const QString &url, const QString &iconSource, const QImage &image)
{
    QString updatedSource = IconImageProvider::storeImage(iconSource, image);
    updateIconRecord(QStringLiteral("bookmarks"), url, updatedSource);
    updateIconRecord(QStringLiteral("history"), url, updatedSource);
}
