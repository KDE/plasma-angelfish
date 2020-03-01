#include "iconimageprovider.h"

#include <QByteArray>
#include <QBuffer>
#include <QDebug>
#include <QImage>
#include <QSqlError>
#include <QSqlQuery>
#include <QString>

IconImageProvider::IconImageProvider() :
    QQuickImageProvider(QQmlImageProviderBase::Image)
{
}

QString IconImageProvider::providerId()
{
    return "angelfish";
}

QString IconImageProvider::storeImage(const QString &iconSource, const QImage &image)
{
    QString prefix_favicon = "image://favicon/";
    if (!iconSource.startsWith(prefix_favicon)) {
        // don't know what to do with it, return as it is
        return iconSource;
    }

    // new uri for image
    QString url = QStringLiteral("image://%1/%2").arg(providerId()).arg(iconSource.mid(prefix_favicon.length()));

    // check if we have that image already
    QSqlQuery query_check;
    query_check.prepare("SELECT 1 FROM icons WHERE url = :url LIMIT 1");
    query_check.bindValue(":url", url);
    if (!query_check.exec()) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query_check.lastQuery();
        qWarning() << query_check.lastError();
        return iconSource; // as something is wrong
    }

    if (query_check.next()) {
        // there is corresponding record in the database already
        // no need to store it again
        qDebug() << "Icon stored already" << url;
        return url;
    }
    query_check.finish();

    // Store new icon
    QByteArray data;
    QBuffer buffer(&data);
    buffer.open(QIODevice::WriteOnly);
    if (!image.save(&buffer, "PNG")) {
         qWarning() << Q_FUNC_INFO << "Failed to save image" << url;
         return iconSource; // as something is wrong
    }

    QSqlQuery query_write;
    query_write.prepare("INSERT INTO icons(url, icon) VALUES (:url, :icon)");
    query_write.bindValue(":url", url);
    query_write.bindValue(":icon", data);
    if (!query_write.exec()) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query_write.lastQuery();
        qWarning() << query_write.lastError();
        return iconSource; // as something is wrong
    }

    return url;
}

QImage IconImageProvider::requestImage(const QString &id, QSize *size, const QSize &/*requestedSize*/)
{
    QSqlQuery query;
    query.prepare("SELECT icon FROM icons WHERE url LIKE :url LIMIT 1");
    query.bindValue(":url", QStringLiteral("image://%1/%2%").arg(providerId()).arg(id));
    if (!query.exec()) {
        qWarning() << Q_FUNC_INFO << "Failed to execute SQL statement";
        qWarning() << query.lastQuery();
        qWarning() << query.lastError();
        return QImage();
    }

    if (query.next()) {
        QImage image = QImage::fromData( query.value(0).toByteArray() );
        if (size) {
            size->setHeight(image.height());
            size->setWidth(image.width());
        }
        return image;
    }

    qWarning() << "Failed to find icon for" << id;
    return QImage();
}
