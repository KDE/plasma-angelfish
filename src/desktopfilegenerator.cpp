/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/


#include "desktopfilegenerator.h"

#include <QStandardPaths>
#include <QQmlEngine>
#include <QQuickImageProvider>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QProcess>

#include <KConfigCore/KDesktopFile>
#include <KConfigCore/KConfigGroup>

DesktopFileGenerator::DesktopFileGenerator(QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
{
}

void DesktopFileGenerator::createDesktopFile(const QString &name, const QString &url, const QString &icon)
{
    const QString location = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    const QString filename = generateFileName(name);
    const QString path = QStringLiteral("%1/%2.desktop").arg(location, filename);
    KConfig desktopFile(path, KConfig::SimpleConfig);

    storeIcon(icon, filename);

    auto desktopEntry = desktopFile.group("Desktop Entry");
    desktopEntry.writeEntry(QStringLiteral("URL"), url);
    desktopEntry.writeEntry(QStringLiteral("Name"), name);
    desktopEntry.writeEntry(QStringLiteral("Exec"), QStringLiteral("%1 %2.desktop").arg(webappCommand(), filename));
    desktopEntry.writeEntry(QStringLiteral("Icon"), filename);

    desktopFile.sync();

    // Refresh homescreen entries on Plasma Mobile
    QProcess buildsycoca;
    buildsycoca.setProgram(QStringLiteral("kbuildsycoca5"));
    buildsycoca.startDetached();
}

bool DesktopFileGenerator::desktopFileExists(const QString &name)
{
    const QString location = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    const QString filename = generateFileName(name);

    auto exists = QFile::exists(QStringLiteral("%1/%2.desktop").arg(location, filename));
    return exists;
}

bool DesktopFileGenerator::removeDesktopFile(const QString &name)
{
    const QString location = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    const QString filename = generateFileName(name);
    return QFile::remove(QStringLiteral("%1/%2.desktop").arg(location, filename));
}

void DesktopFileGenerator::storeIcon(const QString &url, const QString &fileName)
{
    auto *provider = dynamic_cast<QQuickImageProvider *>(m_engine->imageProvider(QStringLiteral("favicon")));

    const QLatin1String prefix_favicon = QLatin1String("image://favicon/");
    const QString providerIconName = url.mid(prefix_favicon.size());

    const QSize szRequested;

    const QString iconLocation = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + QStringLiteral("/icons/hicolor/16x16/apps/");

    QDir().mkpath(iconLocation);

    QFile imageFile(iconLocation + fileName + QStringLiteral(".png"));

    if (!imageFile.open(QIODevice::WriteOnly)) {
        qDebug() << Q_FUNC_INFO << "Failed to open image file";
    }

    switch (provider->imageType()) {
    case QQmlImageProviderBase::Image: {
        const QImage image = provider->requestImage(providerIconName, nullptr, szRequested);
        if (!image.save(&imageFile, "PNG")) {
            qWarning() << Q_FUNC_INFO << "Failed to save image" << url;
            return;
        }
        break;
    }
    case QQmlImageProviderBase::Pixmap: {
        const QPixmap image = provider->requestPixmap(providerIconName, nullptr, szRequested);
        if (!image.save(&imageFile, "PNG")) {
            qWarning() << Q_FUNC_INFO << "Failed to save pixmap" << url;
            return;
        }
        break;
    }
    default:
        qDebug() << "Failed to save unhandled image type";
    }
}

QString DesktopFileGenerator::generateFileName(const QString &name)
{
    QString filename = name.toLower();
    filename.replace(QStringLiteral(" "), QStringLiteral("_"));
    filename.replace(QStringLiteral("'"), QStringLiteral(""));
    filename.replace(QStringLiteral("\""), QStringLiteral(""));
    return filename;
}

QString DesktopFileGenerator::webappCommand()
{
    if (!QStandardPaths::locate(QStandardPaths::RuntimeLocation, QStringLiteral("flatpak-info")).isEmpty()) {
        return QStringLiteral("flatpak run "
                              "--command=angelfish-webapp "
                              "--filesystem=%1 "
                              "org.kde.mobile.angelfish")
                .arg(QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation));
    }

    return QStringLiteral("angelfish-webapp");
}
