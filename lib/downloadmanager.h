// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

// HACK, because QQuickWebEngineDownloadItem is not public API yet
// Teach the compiler that QQuickWebEngineDownloadItem is a QObject subclass,
// Because it can't know due to the forward declaration
class QQuickWebEngineDownloadItem : public QObject {
public:
    enum State {
        DownloadRequested,
        DownloadInProgress,
        DownloadCompleted,
        DownloadCancelled,
        DownloadInterrupted
    };

    QQuickWebEngineDownloadItem() = delete; // Created by the WebEngine, accessible in AngelfishWebProfile

    void accept();
    void cancel();
    void pause();
    void resume();

    QString downloadFileName();
    QUrl url();
    QString mimeType();
    State state();
    QString interruptReasonString();
};

class DownloadManager
{
public:
    DownloadManager();

    static DownloadManager &instance();

    Q_INVOKABLE void addDownload(QQuickWebEngineDownloadItem *download);
    Q_INVOKABLE void removeDownload(const int index);
    const QVector<QQuickWebEngineDownloadItem *> &downloads();

private:
    QVector<QQuickWebEngineDownloadItem *> m_downloads;
};
