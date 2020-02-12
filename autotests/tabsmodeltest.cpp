/*
 *  Copyright 2020 Jonah Brüchert <jbb@kaidan.im>
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

#include "tabsmodel.h"

class TabsModelTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase()
    {
        m_tabsModel = new TabsModel();
    }

    void testInitialTabExists()
    {
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        // Current tab should be initial tab
        QCOMPARE(m_tabsModel->currentTab(), 0);
        QCOMPARE(m_tabsModel->tabs().at(0), "about:blank");
    }

    void testNewTab()
    {
        m_tabsModel->newTab("https://kde.org");
        QCOMPARE(m_tabsModel->tabs().count(), 2);
        QCOMPARE(m_tabsModel->tabs().at(1), "https://kde.org");

        // newly created tab should be current tab now
        QCOMPARE(m_tabsModel->currentTab(), 1);
    }

    void testCurrentTab()
    {
        QCOMPARE(m_tabsModel->tabs().at(m_tabsModel->currentTab()), "https://kde.org");
    }

    void testCloseTab() {
        // Close initial tab, keep kde.org one
        m_tabsModel->closeTab(0);
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        // Check tabs moved properly
        QCOMPARE(m_tabsModel->tabs().at(0), "https://kde.org");
    }

    void testLoad() {
        m_tabsModel->load("https://debian.org");

        // Number of tabs must not change
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        QCOMPARE(m_tabsModel->tabs().at(0), "https://debian.org");
    }

    void testRowCountMatches() {
        QCOMPARE(m_tabsModel->tabs().count(), m_tabsModel->rowCount());
    }

    void testCloseCurrentTab() {
        //
        // Case 1: There is only one tab, a new one should be created
        //
        QCOMPARE(m_tabsModel->tabs().count(), 1);
        m_tabsModel->setCurrentTab(0);
        m_tabsModel->closeTab(0);

        // Check whether a new empty tab was created (count must not be less than one)
        QCOMPARE(m_tabsModel->tabs().count(), 1);
        QCOMPARE(m_tabsModel->tabs().at(0), "about:blank");

        //
        // Case 2: There are multiple tabs
        //
        m_tabsModel->newTab("second");
        m_tabsModel->newTab("third");

        QCOMPARE(m_tabsModel->tabs(), QStringList({"about:blank", "second", "third"}));

        // current tab is 2
        // close tab "second"
        m_tabsModel->closeTab(1);
        // current tab should now be 0, since we reset to first tab if the current tab is closed
        QCOMPARE(m_tabsModel->currentTab(), 0);

        // "second" is indeed gone
        QCOMPARE(m_tabsModel->tabs(), QStringList({"about:blank", "third"}));
    }

    void testSetTab() {
        // tabs are writable by default
        m_tabsModel->setTab(0, "https://debian.org");
        QCOMPARE(m_tabsModel->tabs(), QStringList({"https://debian.org", "third"}));
    }

    void testSetTabsWritable() {
        // tabs are writable by default
        QCOMPARE(m_tabsModel->tabsWritable(), true);

        // Disable tabs writable
        m_tabsModel->setTabsWritable(false);
        QCOMPARE(m_tabsModel->tabsWritable(), false);

        // Enable tabs writable
        m_tabsModel->setTabsWritable(true);
        QCOMPARE(m_tabsModel->tabsWritable(), true);
    }

    void testPrivateMode() {
        // private mode is off by default
        QCOMPARE(m_tabsModel->privateMode(), false);

        m_tabsModel->setPrivateMode(true);
        QCOMPARE(m_tabsModel->privateMode(), true);

        m_tabsModel->setPrivateMode(false);
        QCOMPARE(m_tabsModel->privateMode(), false);
    }
private:
    TabsModel *m_tabsModel;
};

QTEST_MAIN(TabsModelTest);

#include "tabsmodeltest.moc"
