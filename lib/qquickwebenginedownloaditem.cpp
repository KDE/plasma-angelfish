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

QString QQuickWebEngineDownloadItem::downloadDirectory()
{
    return property("downloadDirectory").value<QString>();
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
