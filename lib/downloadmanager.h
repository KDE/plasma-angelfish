// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

class QQuickWebEngineDownloadItem;

class DownloadManager
{
public:
    static DownloadManager &instance();

    Q_INVOKABLE void addDownload(QQuickWebEngineDownloadItem *download);
    Q_INVOKABLE void removeDownload(const int index);
    const QVector<QQuickWebEngineDownloadItem *> &downloads();

private:
    DownloadManager();

    QVector<QQuickWebEngineDownloadItem *> m_downloads;
};
