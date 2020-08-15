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

#include "bookmarkshistorymodel.h"
#include "browsermanager.h"

#include <QDateTime>
#include <QDebug>
#include <QSqlError>

constexpr int QUERY_LIMIT = 1000;

BookmarksHistoryModel::BookmarksHistoryModel()
{
    connect(BrowserManager::instance(), &BrowserManager::databaseTableChanged, this, &BookmarksHistoryModel::onDatabaseChanged);
}

void BookmarksHistoryModel::setActive(bool a)
{
    if (m_active == a)
        return;
    m_active = a;
    if (m_active)
        setQuery();
    else
        clear();
    emit activeChanged();
}

void BookmarksHistoryModel::setBookmarks(bool b)
{
    if (m_bookmarks == b)
        return;
    m_bookmarks = b;
    setQuery();
    emit bookmarksChanged();
}

void BookmarksHistoryModel::setHistory(bool h)
{
    if (m_history == h)
        return;
    m_history = h;
    setQuery();
    emit historyChanged();
}

void BookmarksHistoryModel::setFilter(const QString &f)
{
    if (m_filter == f)
        return;
    m_filter = f;
    setQuery();
    emit filterChanged();
}

void BookmarksHistoryModel::onDatabaseChanged(const QString &table)
{
    if ((table == QLatin1String("bookmarks") && m_bookmarks) || (table == QLatin1String("history") && m_history))
        setQuery();
}

void BookmarksHistoryModel::setQuery()
{
    if (!m_active)
        return;

    QString command;
    const QString b = QStringLiteral("SELECT rowid AS id, url, title, icon, :now - lastVisited AS lastVisitedDelta, %1 AS bookmarked FROM %2 ");
    const QLatin1String filter = m_filter.isEmpty() ? QLatin1String() : QLatin1String("WHERE url LIKE '%' || :filter || '%' OR title LIKE '%' || :filter || '%'");
    const bool includeHistory = m_history && !(m_bookmarks && m_filter.isEmpty());

    if (m_bookmarks)
        command = b.arg(1).arg(QLatin1String("bookmarks")) + filter;

    if (m_bookmarks && includeHistory)
        command += QLatin1String("\n UNION \n");

    if (includeHistory)
        command += b.arg(0).arg(QLatin1String("history")) + filter;

    command += QLatin1String("\n ORDER BY bookmarked DESC, lastVisitedDelta ASC");

    if (includeHistory)
        command += QStringLiteral("\n LIMIT %1").arg(QUERY_LIMIT);

    const qint64 ref = QDateTime::currentSecsSinceEpoch();
    QSqlQuery query;
    if (!query.prepare(command)) {
        qWarning() << Q_FUNC_INFO << "Failed to prepare SQL statement";
        qWarning() << query.lastQuery();
        qWarning() << query.lastError();
        return;
    }

    if (!m_filter.isEmpty())
        query.bindValue(QStringLiteral(":filter"), m_filter);

    query.bindValue(QStringLiteral(":now"), ref);

    if (!query.exec()) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query.lastQuery();
        qWarning() << query.lastError();
        return;
    }

    SqlQueryModel::setQuery(query);
}
