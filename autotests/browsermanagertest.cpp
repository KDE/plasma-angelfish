/*
 *  Copyright 2019 Jonah Brüchert <jbb@kaidan.im>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License version 2 as published by the Free Software Foundation;
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public License
 *  along with this library; see the file COPYING.LIB.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301, USA.
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
