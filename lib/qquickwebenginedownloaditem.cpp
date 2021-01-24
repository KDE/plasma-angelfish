#include "qquickwebenginedownloaditem.h"

#include <QMetaObject>
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

QString QQuickWebEngineDownloadItem::downloadDirectory() const
{
    return property("downloadDirectory").value<QString>();
}

QString QQuickWebEngineDownloadItem::downloadFileName() const
{
    return property("downloadFileName").value<QString>();
}

QUrl QQuickWebEngineDownloadItem::url() const
{
    return property("url").value<QUrl>();
}

QString QQuickWebEngineDownloadItem::mimeType() const
{
    return property("mimeType").value<QString>();
}

QQuickWebEngineDownloadItem::State QQuickWebEngineDownloadItem::state() const
{
    return static_cast<State>(property("state").value<int>());
}

QString QQuickWebEngineDownloadItem::interruptReasonString() const
{
    return property("interruptReasonString").toString();
}
