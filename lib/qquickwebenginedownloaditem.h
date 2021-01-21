#pragma once

#include <QObject>

// HACK, because QQuickWebEngineDownloadItem is not public API yet
// Teach the compiler that QQuickWebEngineDownloadItem is a QObject subclass,
// Because it can't know due to the forward declaration
class QQuickWebEngineDownloadItem : public QObject
{
public:
    enum State {
        DownloadRequested,
        DownloadInProgress,
        DownloadCompleted,
        DownloadCancelled,
        DownloadInterrupted,
    };

    QQuickWebEngineDownloadItem() = delete; // Created by the WebEngine, accessible in AngelfishWebProfile

    void accept();
    void cancel();
    void pause();
    void resume();

    QString downloadDirectory();
    QString downloadFileName();
    QUrl url();
    QString mimeType();
    State state();
    QString interruptReasonString();
};
