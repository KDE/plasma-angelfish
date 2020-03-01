// From https://wiki.qt.io/How_to_Use_a_QSqlQueryModel_in_QML

#include "sqlquerymodel.h"

#include <QDebug>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlField>

SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent)
{
}

void SqlQueryModel::setQuery(const QSqlQuery &query)
{
    QSqlQueryModel::setQuery(query);
    generateRoleNames();
}

void SqlQueryModel::generateRoleNames()
{
    m_roleNames.clear();
    for ( int i = 0; i < record().count(); i++ ) {
        m_roleNames.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
    }
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const
{
    if (role > Qt::UserRole) {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        return QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return QVariant();
}

QHash<int, QByteArray> SqlQueryModel::roleNames() const
{
    return m_roleNames;
}

