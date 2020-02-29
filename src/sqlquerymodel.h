// From https://wiki.qt.io/How_to_Use_a_QSqlQueryModel_in_QML

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
