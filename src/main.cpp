#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QCommandLineParser>
#include <QCommandLineOption>

#include "browsermanager.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("angelfish");

    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:///webbrowser.qml")));

    auto *browserManager = new AngelFish::BrowserManager(engine.rootContext());
    engine.rootContext()->setContextProperty("browserManager", browserManager);

    qmlRegisterUncreatableType<AngelFish::BrowserManager>("org.kde.mobile.angelfish", 1, 0, "BrowserManager", "");
    qmlRegisterType<QAbstractListModel>();


    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    int ret = app.exec();
    return ret;
}
