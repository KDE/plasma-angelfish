// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractItemModel>

class DownloadsModel : public QAbstractListModel
{
    Q_OBJECT

    enum Role { UrlRole, FileNameRole, DownloadRole, MimeTypeIconRole };

public:
    explicit DownloadsModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void removeDownload(const int index);
};
