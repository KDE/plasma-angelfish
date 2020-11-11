/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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
    BookmarksHistoryModel(QObject *parent = nullptr);

    bool active() const
    {
        return m_active;
    }
    void setActive(bool a);

    bool bookmarks() const
    {
        return m_bookmarks;
    }
    void setBookmarks(bool b);

    bool history() const
    {
        return m_history;
    }
    void setHistory(bool h);

    QString filter() const
    {
        return m_filter;
    }
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
