/*
 *  SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 *  SPDX-License-Identifier: LGPL-2.0-only
 */

#include <QtTest/QTest>
#include <QSignalSpy>
#include <QCoreApplication>
#include <QStandardPaths>

#include "dbmanager.h"
#include "sqlquerymodel.h"

class TabsModelTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase()
    {
        QCoreApplication::setOrganizationName("autotests");
        QCoreApplication::setApplicationName("angelfish_dbmanagertest");
        QDir dir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));
        dir.mkpath(".");

        m_dbmanager = new DBManager();
    }

    void testAddBookmark()
    {
        QSignalSpy spy(m_dbmanager, &DBManager::databaseTableChanged);
        m_dbmanager->addBookmark({{"url", "https://kde.org"}, {"title", "KDE"}, {"icon", "TESTDATA"}});

        QCOMPARE(spy.count(), 1);
    }

    void testAddToHistory()
    {
        QSignalSpy spy(m_dbmanager, &DBManager::databaseTableChanged);
        m_dbmanager->addToHistory({{"url", "https://kde.org"}, {"title", "KDE"}, {"icon", "TESTDATA"}});

        QCOMPARE(spy.count(), 1);
    }

    void testLastVisited()
    {
        QSignalSpy spy(m_dbmanager, &DBManager::databaseTableChanged);
        m_dbmanager->updateLastVisited("https://kde.org");

        // Will be updated in both tables
        QCOMPARE(spy.count(), 2);
    }

    void testRemoveBookmark()
    {
        QSignalSpy spy(m_dbmanager, &DBManager::databaseTableChanged);
        m_dbmanager->removeBookmark("https://kde.org");

        QCOMPARE(spy.count(), 1);
    }

    void testRemoveFromHistory()
    {
        QSignalSpy spy(m_dbmanager, &DBManager::databaseTableChanged);
        m_dbmanager->removeBookmark("https://kde.org");

        QCOMPARE(spy.count(), 1);
    }

    void testSqlQueryModelRoleNames()
    {
        auto model = new SqlQueryModel();
        model->setQuery(QSqlQuery("SELECT * FROM history"));

        QHash<int, QByteArray> expectedRoleNames = {
            { Qt::UserRole + 1, "url"},
            { Qt::UserRole + 2, "title"},
            { Qt::UserRole + 3, "icon"},
            { Qt::UserRole + 4, "lastVisited"}
        };
        QCOMPARE(model->roleNames(), expectedRoleNames);
    }
private:
    DBManager *m_dbmanager;
};

QTEST_GUILESS_MAIN(TabsModelTest);

#include "dbmanagertest.moc"
