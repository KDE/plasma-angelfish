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

#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QString>
#include <QSqlQuery>

namespace AngelFish {

/**
 * @class DBManager
 * @short Class for database initialization and applying changes in its records
 */
class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QObject *parent = nullptr);

signals:
    // emitted with the name of the table that has been changed
    void databaseTableChanged(QString table);

public:
    void addBookmark(const QVariantMap &bookmarkdata);
    void removeBookmark(const QString &url);

    void addToHistory(const QVariantMap &pagedata);
    void removeFromHistory(const QString &url);

    void updateIcon(const QString &url, const QString &iconSource);
    void lastVisited(const QString &url);

private:
    // version of database schema
    int version();
    void setVersion(int v);

    // migration from earlier versions
    bool migrate();
    bool migrateTo1();

    // limit the size of history table
    void trimHistory();

    // execute SQL statement
    bool execute(const QString &command);
    bool execute(QSqlQuery &query);

    // methods for manipulation of bookmarks or history tables
    void addRecord(const QString &table, const QVariantMap &pagedata);
    void removeRecord(const QString &table, const QString &url);
    void updateIconRecord(const QString &table, const QString &url, const QString &iconSource);
    void lastVisitedRecord(const QString &table, const QString &url);
};

} // namespace

#endif // DBMANAGER_H
