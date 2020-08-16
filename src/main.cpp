/*
    Copyright (C) 2019 Jonah Brüchert <jbb.prv@gmx.de>

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
#include <KDBusService>
#include <KWindowSystem>

#include "bookmarkshistorymodel.h"
#include "browsermanager.h"
#include "iconimageprovider.h"
#include "tabsmodel.h"
#include "urlobserver.h"
#include "urlutils.h"
#include "useragent.h"
#include "desktopfilegenerator.h"
#include "angelfishsettings.h"

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
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("mobile.kde.org"));
    QCoreApplication::setApplicationName(QStringLiteral("angelfish"));

#if QT_VERSION <= QT_VERSION_CHECK(5, 14, 0)
    QtWebEngine::initialize();
#endif

    // Command line parser
    QCommandLineParser parser;
    parser.addPositionalArgument(QStringLiteral("url"), i18n("URL to open"), QStringLiteral("[url]"));
    parser.addHelpOption();
    parser.process(app);

    // QML loading
    QQmlApplicationEngine engine;

    // Open links in the already running window when e.g clicked on in another application.
    KDBusService service(KDBusService::Unique, &app);
    QObject::connect(&service, &KDBusService::activateRequested, &app, [&parser, &engine](const QStringList &arguments) {
        parser.parse(arguments);

        if (!parser.positionalArguments().isEmpty()) {
            const QString initialUrl = QUrl::fromUserInput(parser.positionalArguments().constFirst()).toString();
            auto *webbrowserWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
            if (!webbrowserWindow) {
                qWarning() << "No webbrowser window is open, can't open the url";
                return;
            }
            const auto *pageStack = webbrowserWindow->property("pageStack").value<QObject *>();
            const auto *initialPage = pageStack->property("initialPage").value<QObject *>();

            // This should be initialPage->findChild<TabsModel *>(QStringLiteral("regularTabsObject")), for some reason
            // it doesn't find our tabsModel.
            const auto children = initialPage->children();
            auto *regularTabs = *std::find_if(children.cbegin(), children.cend(), [](const QObject *child) {
                return child->objectName() == QStringLiteral("regularTabsObject");
            });

            auto *tabsModel = regularTabs->property("tabsModel").value<TabsModel *>();
            // Open new tab with requested url
            tabsModel->newTab(initialUrl);

            // Move window to the front
            KWindowSystem::raiseWindow(webbrowserWindow->winId());
        }
    });

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.addImageProvider(IconImageProvider::providerId(), new IconImageProvider(&engine));

    // initial url command line parameter
    if (!parser.positionalArguments().isEmpty()) {
        const QString initialUrl = QUrl::fromUserInput(parser.positionalArguments().constFirst()).toString();
        BrowserManager::instance()->setInitialUrl(initialUrl);
    }

    // Exported types
    qmlRegisterType<BookmarksHistoryModel>("org.kde.mobile.angelfish", 1, 0, "BookmarksHistoryModel");
    qmlRegisterType<UrlObserver>("org.kde.mobile.angelfish", 1, 0, "UrlObserver");
    qmlRegisterType<UserAgent>("org.kde.mobile.angelfish", 1, 0, "UserAgentGenerator");
    qmlRegisterType<TabsModel>("org.kde.mobile.angelfish", 1, 0, "TabsModel");

    // URL utils
    qmlRegisterSingletonType<UrlUtils>("org.kde.mobile.angelfish", 1, 0, "UrlUtils", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(new UrlUtils());
    });

    // Browser Manager
    qmlRegisterSingletonType<BrowserManager>("org.kde.mobile.angelfish", 1, 0, "BrowserManager", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(BrowserManager::instance());
    });

    // Angelfish-webapp generator
    qmlRegisterSingletonType<DesktopFileGenerator>("org.kde.mobile.angelfish", 1, 0, "DesktopFileGenerator", [](QQmlEngine *engine, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(new DesktopFileGenerator(engine));
    });

    qmlRegisterSingletonInstance<AngelfishSettings>("org.kde.mobile.angelfish", 1, 0, "Settings", AngelfishSettings::self());

    QObject::connect(QApplication::instance(), &QCoreApplication::aboutToQuit, QApplication::instance(), [] {
        AngelfishSettings::self()->save();
    });

    // Load QML
    engine.load(QUrl(QStringLiteral("qrc:///webbrowser.qml")));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
