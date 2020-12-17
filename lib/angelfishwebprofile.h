// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQuickWebEngineProfile>
#include <QWebEngineUrlRequestInterceptor>

class QWebEngineNotification;

class AngelfishWebProfile : public QQuickWebEngineProfile
{
    Q_OBJECT

    Q_PROPERTY(QObject *questionLoader MEMBER m_questionLoader NOTIFY questionLoaderChanged)
    Q_PROPERTY(QWebEngineUrlRequestInterceptor *urlInterceptor WRITE setUrlInterceptor READ urlInterceptor NOTIFY urlInterceptorChanged)

public:
    explicit AngelfishWebProfile(QObject *parent = nullptr);

    Q_SIGNAL void questionLoaderChanged();
    Q_SIGNAL void urlInterceptorChanged();

    QWebEngineUrlRequestInterceptor *urlInterceptor() const;
    void setUrlInterceptor(QWebEngineUrlRequestInterceptor *urlRequestInterceptor);

private:
    void handleDownload(QQuickWebEngineDownloadItem *downloadItem);
    void handleDownloadFinished(QQuickWebEngineDownloadItem *downloadItem);
    void showNotification(QWebEngineNotification *webNotification);

    QObject *m_questionLoader;

    // A valid property needs a read function, and there is no getter in QQuickWebEngineProfile
    // so store a pointer ourselves
    QWebEngineUrlRequestInterceptor *m_urlInterceptor;
};
