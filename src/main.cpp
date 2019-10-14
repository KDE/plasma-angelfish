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

#include "browsermanager.h"
#include "urlfilterproxymodel.h"
#include "urlmodel.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("mobile.kde.org");
    QCoreApplication::setApplicationName("angelfish");

    // Command line parser
    QCommandLineParser parser;
    parser.addPositionalArgument("url", i18n("URL to open"), "[url]");
    parser.addOption({ "webapp-container", i18n("Start without UI") });
    parser.addHelpOption();
    parser.process(app);

    // QML loading
    QQmlApplicationEngine engine;

    // Setup QtWebEngine
    qputenv("QTWEBENGINE_DIALOG_SET", "QtQuickControls2");
    QtWebEngine::initialize();

    // initial url command line parameter
    QString initialUrl;
    if (!parser.positionalArguments().isEmpty())
        initialUrl = QUrl::fromUserInput(parser.positionalArguments()[0].toUtf8()).toEncoded();
    engine.rootContext()->setContextProperty("initialUrl", initialUrl);

    engine.rootContext()->setContextProperty("webappcontainer", parser.isSet("webapp-container"));

    // Browser manager
    qmlRegisterType<AngelFish::BrowserManager>("org.kde.mobile.angelfish", 1, 0,
                                                          "BrowserManager");
    qmlRegisterType<UrlFilterProxyModel>("org.kde.mobile.angelfish", 1, 0,
                                                          "UrlFilterProxyModel");
    engine.load(QUrl(QStringLiteral("qrc:///webbrowser.qml")));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
