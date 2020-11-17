// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "adblockfilterlistsmodel.h"

#include "adblockfilterlistsmanager.h"
#include "angelfishsettings.h"
#include "adblockurlinterceptor.h"

AdblockFilterListsModel::AdblockFilterListsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&m_manager, &AdblockFilterListsManager::refreshFinished,
            this, &AdblockFilterListsModel::refreshFinished);
    connect(&m_manager, &AdblockFilterListsManager::refreshFinished,
            this, &AdblockFilterListsModel::resetAdblock);
}

QVariant AdblockFilterListsModel::data(const QModelIndex &index, int role) const
{
    switch(role) {
    case Qt::DisplayRole:
        return m_manager.filterLists().at(index.row()).name;
    case Role::Url:
        return m_manager.filterLists().at(index.row()).url;
    }

    return {};
}

QHash<int, QByteArray> AdblockFilterListsModel::roleNames() const
{
    return {
        {Qt::DisplayRole, "displayName"},
        {Role::Url, "url"}
    };
}

int AdblockFilterListsModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_manager.filterLists().size();;
}

void AdblockFilterListsModel::addFilterList(const QString &name, const QUrl &url)
{
    const auto currentSize = m_manager.filterLists().size();
    beginInsertRows({}, currentSize, currentSize);
    m_manager.addFilterList(name, url);
    endInsertRows();
}

void AdblockFilterListsModel::removeFilterList(const int index)
{
    beginRemoveRows({}, index, index);
    m_manager.removeFilterList(index);
    endRemoveRows();
}

void AdblockFilterListsModel::refreshLists()
{
    m_manager.refreshLists();
}

void AdblockFilterListsModel::resetAdblock()
{
    AdblockUrlInterceptor::instance().resetAdblock();
}

