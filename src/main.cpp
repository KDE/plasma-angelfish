#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QtWebEngine>

#include "browsermanager.h"
#include "urlfilterproxymodel.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("angelfish");

    // Command line parser
    QCommandLineParser parser;
    QCommandLineOption helpOption = parser.addHelpOption();
    parser.addPositionalArgument("url", "An url to open", "[url]");
    parser.addOption({"webapp-container", "Start without ui"});
    parser.parse(QGuiApplication::arguments());

    // QML loading
    QQmlApplicationEngine engine;
    QtWebEngine::initialize();

    // initial url command line parameter
    QString initialUrl;
    if (!parser.positionalArguments().isEmpty())
        initialUrl = QUrl::fromUserInput(parser.positionalArguments()[0].toUtf8()).toEncoded();
    engine.rootContext()->setContextProperty("initialUrl", initialUrl);

    engine.rootContext()->setContextProperty("webappcontainer", parser.isSet("webapp-container"));

    // Browser manager
    AngelFish::BrowserManager *browserManager = new AngelFish::BrowserManager(engine.rootContext());
    engine.rootContext()->setContextProperty("browserManager", browserManager);

    UrlFilterProxyModel *proxy = new UrlFilterProxyModel(browserManager);
    proxy->setSourceModel(browserManager->history());
    proxy->setFilterCaseSensitivity(Qt::CaseInsensitive);
    engine.rootContext()->setContextProperty("urlFilter", proxy);

    qmlRegisterUncreatableType<AngelFish::BrowserManager>("org.kde.mobile.angelfish", 1, 0, "BrowserManager", "");
    qmlRegisterType<QAbstractListModel>();

    engine.load(QUrl(QStringLiteral("qrc:///webbrowser.qml")));

    // Error handling
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }


    int ret = app.exec();
    return ret;
}
