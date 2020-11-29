// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "angelfishwebprofile.h"

#include <QQuickItem>
#include <KLocalizedString>
#include <QGuiApplication>
#include <QQuickWindow>

AngelfishWebProfile::AngelfishWebProfile(QObject *parent)
    : QQuickWebEngineProfile(parent)
    , m_questionLoader(nullptr)
    , m_urlInterceptor(nullptr)
{
    connect(this, &QQuickWebEngineProfile::downloadRequested, this, &AngelfishWebProfile::handleDownload);
    connect(this, &QQuickWebEngineProfile::downloadFinished, this, &AngelfishWebProfile::handleDownloadFinished);
}

void AngelfishWebProfile::handleDownload(QQuickWebEngineDownloadItem *downloadItem)
{
    // if we don't accept the request right away, it will be deleted
    QMetaObject::invokeMethod(downloadItem, "accept");
    // therefore just stop the download again as quickly as possible,
    // and ask the user for confirmation
    QMetaObject::invokeMethod(downloadItem, "pause");

    if (m_questionLoader) {
        m_questionLoader->setProperty("source", QStringLiteral("qrc:/DownloadQuestion.qml"));

        QQuickItem *question = m_questionLoader->property("item").value<QQuickItem *>();
        if (question) {
            question->setProperty("download", QVariant::fromValue(downloadItem));
            question->setVisible(true);
        }
    }
}

void AngelfishWebProfile::handleDownloadFinished(QQuickWebEngineDownloadItem *downloadItem)
{
    enum State {
        DownloadRequested,
        DownloadInProgress,
        DownloadCompleted,
        DownloadCancelled,
        DownloadInterrupted
    };

    QQuickWindow *window = static_cast<QQuickItem *>(m_questionLoader)->window();
    const auto passiveNotification = [window](const QString &text) {
        QMetaObject::invokeMethod(window, "showPassiveNotification",
                                  Q_ARG(QVariant, text),
                                  Q_ARG(QVariant, {}),
                                  Q_ARG(QVariant, {}),
                                  Q_ARG(QVariant, {}));
    };

    const int state = downloadItem->property("state").value<int>();
    switch (state) {
    case DownloadCompleted:
        qDebug() << "download finished";
        passiveNotification(i18n("Download finished"));
        break;
    case DownloadInterrupted:
        qDebug() << "Download failed";
        passiveNotification(i18n("Download failed"));
        qDebug() << "Download interrupt reason:" << downloadItem->property("interruptReason");
        break;
    case DownloadCancelled:
        qDebug() << "Download cancelled by the user";
        break;
    }
}

QWebEngineUrlRequestInterceptor *AngelfishWebProfile::urlInterceptor() const
{
    return m_urlInterceptor;
}

void AngelfishWebProfile::setUrlInterceptor(QWebEngineUrlRequestInterceptor *urlRequestInterceptor)
{
    setUrlRequestInterceptor(urlRequestInterceptor);
    m_urlInterceptor = urlRequestInterceptor;
}
