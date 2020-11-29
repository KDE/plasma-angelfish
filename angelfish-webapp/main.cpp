/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb.prv@gmx.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>
#include <QtWebEngine>

#include <KLocalizedContext>
#include <KLocalizedString>
#include <KDesktopFile>
#include <KAboutData>

#include "bookmarkshistorymodel.h"
#include "browsermanager.h"
#include "iconimageprovider.h"
#include "tabsmodel.h"
#include "urlutils.h"
#include "useragent.h"
#include "angelfishsettings.h"
#include "angelfishwebprofile.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    // Setup QtWebEngine
    qputenv("QTWEBENGINE_DIALOG_SET", "QtQuickControls2");
#if QT_VERSION > QT_VERSION_CHECK(5, 14, 0)
    QtWebEngine::initialize();
#endif

    QApplication app(argc, argv);
    //QCoreApplication::setOrganizationName("KDE");
    //QCoreApplication::setOrganizationDomain("mobile.kde.org");
    //QCoreApplication::setApplicationName("angelfish");

#if QT_VERSION <= QT_VERSION_CHECK(5, 14, 0)
    QtWebEngine::initialize();
#endif

    // Command line parser
    QCommandLineParser parser;
    parser.addPositionalArgument(QStringLiteral("desktopfile"), i18n("desktop file to open"), QStringLiteral("[file]"));
    parser.addHelpOption();
    parser.process(app);

    // QML loading
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.addImageProvider(IconImageProvider::providerId(), new IconImageProvider(&engine));

    if (parser.positionalArguments().isEmpty()) {
        return 1;
    }

    const QString fileName = parser.positionalArguments().constFirst();
    const KDesktopFile desktopFile(fileName);
    if (desktopFile.readUrl().isEmpty()) {
        return 2;
    }
    const QString initialUrl = QUrl::fromUserInput(desktopFile.readUrl()).toString();

    const QString appName = desktopFile.readName().toLower().replace(QLatin1Char(' '), QLatin1Char('-')) + QStringLiteral("-angelfish-webapp");
    KAboutData aboutData(appName.toLower(), desktopFile.readName(),
                          QStringLiteral("0.1"),
                          i18n("Angelfish Web App runtime"),
                          KAboutLicense::GPL,
                          i18n("Copyright 2020 Angelfish developers"));
    QApplication::setWindowIcon(QIcon::fromTheme(desktopFile.readIcon()));
    aboutData.addAuthor(i18n("Marco Martin"), QString(), QStringLiteral("mart@kde.org"));

    KAboutData::setApplicationData(aboutData);

    // Exported types
    qmlRegisterType<BookmarksHistoryModel>("org.kde.mobile.angelfish", 1, 0, "BookmarksHistoryModel");
    qmlRegisterType<UserAgent>("org.kde.mobile.angelfish", 1, 0, "UserAgentGenerator");
    qmlRegisterType<TabsModel>("org.kde.mobile.angelfish", 1, 0, "TabsModel");
    qmlRegisterType<AngelfishWebProfile>("org.kde.mobile.angelfish", 1, 0, "AngelfishWebProfile");

    // URL utils
    qmlRegisterSingletonType<UrlUtils>("org.kde.mobile.angelfish", 1, 0, "UrlUtils", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(new UrlUtils());
    });

    BrowserManager::instance()->setInitialUrl(initialUrl);

    // Browser Manager
    qmlRegisterSingletonType<BrowserManager>("org.kde.mobile.angelfish", 1, 0, "BrowserManager", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(BrowserManager::instance());
    });

    // Settings are read from WebView which we use as super class for WebAppView
    qmlRegisterSingletonInstance<AngelfishSettings>("org.kde.mobile.angelfish", 1, 0, "Settings", AngelfishSettings::self());

    Q_INIT_RESOURCE(resources);

    // Load QML
    engine.load(QUrl(QStringLiteral("qrc:///webapp.qml")));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
