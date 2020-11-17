// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QNetworkAccessManager>

#include "adblockfilterlistsmanager.h"

class AdblockFilterListsModel : public QAbstractListModel
{
    Q_OBJECT

    enum Role {
        Url = Qt::UserRole + 1,
    };

public:
    explicit AdblockFilterListsModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent) const override;

    Q_SLOT void addFilterList(const QString &name, const QUrl &url);
    Q_SLOT void removeFilterList(const int index);

    Q_SLOT void refreshLists();
    Q_SLOT void resetAdblock();
    Q_SIGNAL void refreshFinished();

private:
    AdblockFilterListsManager m_manager;
};
