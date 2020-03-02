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

#ifndef BOOKMARKSHISTORYMODEL_H
#define BOOKMARKSHISTORYMODEL_H

#include "sqlquerymodel.h"

/**
 * @class BookmarksHistoryModel
 * @short Model for listing Bookmarks and History items.
 */
class BookmarksHistoryModel : public SqlQueryModel
{
    Q_OBJECT

    // while active, data is shown and changes in the used database table(s)
    // will trigger new query
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    // set to true for including bookmarks
    Q_PROPERTY(bool bookmarks READ bookmarks WRITE setBookmarks NOTIFY bookmarksChanged)
    // set to true for including history
    Q_PROPERTY(bool history READ history WRITE setHistory NOTIFY historyChanged)
    // set to string to filter url or title by it. without filter set, only
    // bookmarks are shown
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)

public:
    BookmarksHistoryModel();

    bool active() const { return m_active; }
    void setActive(bool a);

    bool bookmarks() const { return m_bookmarks; }
    void setBookmarks(bool b);

    bool history() const { return m_history; }
    void setHistory(bool h);

    QString filter() const { return m_filter; }
    void setFilter(const QString &f);


signals:
    void activeChanged();
    void bookmarksChanged();
    void historyChanged();
    void filterChanged();

private:
    void onDatabaseChanged(const QString &table);

    void setQuery();

private:
    bool m_active = true;
    bool m_bookmarks = false;
    bool m_history = false;
    QString m_filter;
};

#endif // BOOKMARKSHISTORYMODEL_H
