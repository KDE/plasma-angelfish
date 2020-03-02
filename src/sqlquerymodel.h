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

// Based on https://wiki.qt.io/How_to_Use_a_QSqlQueryModel_in_QML

#ifndef SQLQUERYMODEL_H
#define SQLQUERYMODEL_H

#include <QSqlQueryModel>

/**
 * @class SqlQueryModel
 * @short Base class that can be used by models backed by SQL query
 */
class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT

public:
    SqlQueryModel(QObject *parent = nullptr);

    // SQL query has to be executed when calling this
    // method. Note that the query result will determine
    // model role names.
    void setQuery(const QSqlQuery &query);

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    void generateRoleNames();

private:
    QHash<int, QByteArray> m_roleNames;
};

#endif // SQLQUERYMODEL_H
