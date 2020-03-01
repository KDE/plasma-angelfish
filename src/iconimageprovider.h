#ifndef ICONIMAGEPROVIDER_H
#define ICONIMAGEPROVIDER_H

#include <QQuickImageProvider>

class IconImageProvider : public QQuickImageProvider
{
public:
    IconImageProvider();

    virtual QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

    // store image into the database if it is missing. Return new
    // image:// uri that should be used to fetch the icon
    static QString storeImage(const QString &iconSource, const QImage &image);

    static QString providerId();
};

#endif // ICONIMAGEPROVIDER_H
