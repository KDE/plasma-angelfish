/*
 *  SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
 *
 *  SPDX-License-Identifier: LGPL-2.0-only
 */

#include <QtTest/QTest>

#include <QSignalSpy>
#include <QUrl>
#include <QStandardPaths>

#include "browsermanager.h"
#include "urlutils.h"
#include "angelfishsettings.h"

class UserAgentTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase()
    {
        QCoreApplication::setOrganizationName("autotests");
        QCoreApplication::setApplicationName("angelfish_dbmanagertest");
        QDir dir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));
        dir.mkpath(".");

        m_browserManager = BrowserManager::instance();
    }

    void cleanupTestCase()
    {
        delete m_browserManager;
    }

    void urlFromUserInput()
    {
        const QString incompleteUrl = QStringLiteral("kde.org");
        const QString completeUrl = QStringLiteral("http://kde.org");

        QCOMPARE(UrlUtils::urlFromUserInput(incompleteUrl), completeUrl);
    }
private:
    BrowserManager *m_browserManager;
};

QTEST_GUILESS_MAIN(UserAgentTest);

#include "browsermanagertest.moc"
