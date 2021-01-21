// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "downloadmanager.h"

#include <QUrl>
#include <QVariant>

#include "qquickwebenginedownloaditem.h"

DownloadManager::DownloadManager()
{
}

DownloadManager &DownloadManager::instance()
{
    static DownloadManager instance;
    return instance;
}

void DownloadManager::addDownload(QQuickWebEngineDownloadItem *download)
{
    m_downloads.push_back(download);
}

void DownloadManager::removeDownload(const int index)
{
    m_downloads.at(index)->cancel();
    m_downloads.removeAt(index);
}

const QVector<QQuickWebEngineDownloadItem *> &DownloadManager::downloads()
{
    return m_downloads;
}
