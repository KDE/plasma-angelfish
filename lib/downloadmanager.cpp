// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "downloadmanager.h"

#include <QUrl>
#include <QVariant>

void QQuickWebEngineDownloadItem::accept()
{
    QMetaObject::invokeMethod(this, "accept");
}

void QQuickWebEngineDownloadItem::cancel()
{
    QMetaObject::invokeMethod(this, "cancel");
}

void QQuickWebEngineDownloadItem::pause()
{
    QMetaObject::invokeMethod(this, "pause");
}

void QQuickWebEngineDownloadItem::resume()
{
    QMetaObject::invokeMethod(this, "resume");
}

QString QQuickWebEngineDownloadItem::downloadFileName()
{
    return property("downloadFileName").value<QString>();
}

QUrl QQuickWebEngineDownloadItem::url()
{
    return property("url").value<QUrl>();
}

QString QQuickWebEngineDownloadItem::mimeType()
{
    return property("mimeType").value<QString>();
}

QQuickWebEngineDownloadItem::State QQuickWebEngineDownloadItem::state()
{
    return static_cast<State>(property("state").value<int>());
}

QString QQuickWebEngineDownloadItem::interruptReasonString()
{
    return property("interruptReasonString").toString();
}

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
