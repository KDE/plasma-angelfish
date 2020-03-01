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
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QtWebEngine>

#include <KLocalizedString>
#include <KLocalizedContext>

#include "bookmarkshistorymodel.h"
#include "browsermanager.h"
#include "iconimageprovider.h"
#include "tabsmodel.h"
#include "urlutils.h"
#include "useragent.h"

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
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("mobile.kde.org");
    QCoreApplication::setApplicationName("angelfish");

#if QT_VERSION <= QT_VERSION_CHECK(5, 14, 0)
    QtWebEngine::initialize();
#endif

    // Command line parser
    QCommandLineParser parser;
    parser.addPositionalArgument("url", i18n("URL to open"), "[url]");
    parser.addOption({ "webapp-container", i18n("Start without UI") });
    parser.addHelpOption();
    parser.process(app);

    // QML loading
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.addImageProvider(IconImageProvider::providerId(), new IconImageProvider(&engine));

    // initial url command line parameter
    QString initialUrl;
    if (!parser.positionalArguments().isEmpty())
        initialUrl = QUrl::fromUserInput(parser.positionalArguments().first()).toString();

    engine.rootContext()->setContextProperty("webappcontainer", parser.isSet("webapp-container"));

    // Exported types
    qmlRegisterType<BookmarksHistoryModel>("org.kde.mobile.angelfish", 1, 0, "BookmarksHistoryModel");
    qmlRegisterType<UserAgent>("org.kde.mobile.angelfish", 1, 0, "UserAgentGenerator");
    qmlRegisterType<TabsModel>("org.kde.mobile.angelfish", 1, 0, "TabsModel");

    // URL utils
    qmlRegisterSingletonType<UrlUtils>("org.kde.mobile.angelfish", 1, 0, "UrlUtils", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(new UrlUtils());
    });

    BrowserManager::instance()->setInitialUrl(initialUrl);

    // Browser Manager
    qmlRegisterSingletonType<BrowserManager>("org.kde.mobile.angelfish", 1, 0, "BrowserManager", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(BrowserManager::instance());
    });

    // Load QML
    engine.load(QUrl(QStringLiteral("qrc:///webbrowser.qml")));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
