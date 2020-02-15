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
        QCOMPARE(m_tabsModel->tab(0), TabState("about:blank", false));
    }

    void testNewTab()
    {
        m_tabsModel->newTab("https://kde.org");
        QCOMPARE(m_tabsModel->tabs().count(), 2);
        qDebug() << m_tabsModel->tab(1).url() << m_tabsModel->tab(0).isMobile();
        QCOMPARE(m_tabsModel->tab(1), TabState("https://kde.org", false));

        // newly created tab should be current tab now
        QCOMPARE(m_tabsModel->currentTab(), 1);
    }

    void testCurrentTab()
    {
        QCOMPARE(m_tabsModel->tabs().at(m_tabsModel->currentTab()), TabState("https://kde.org", false));
    }

    void testCloseTab() {
        // Close initial tab, keep kde.org one
        m_tabsModel->closeTab(0);
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        // Check tabs moved properly
        QCOMPARE(m_tabsModel->tabs().at(0), TabState("https://kde.org", false));
    }

    void testLoad() {
        m_tabsModel->load("https://debian.org");

        // Number of tabs must not change
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        QCOMPARE(m_tabsModel->tabs().at(0), TabState("https://debian.org", false));
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
        QCOMPARE(m_tabsModel->tabs().at(0), TabState("about:blank", false));

        //
        // Case 2: There are multiple tabs
        //
        m_tabsModel->newTab("second");
        m_tabsModel->newTab("third");

        QCOMPARE(m_tabsModel->tabs(), QVector<TabState>({TabState("about:blank", false), TabState("second", false), TabState("third", false)}));

        // current tab is 2
        // close tab "second"
        m_tabsModel->closeTab(1);
        // current tab should now be 0, since we reset to first tab if the current tab is closed
        QCOMPARE(m_tabsModel->currentTab(), 0);

        // "second" is indeed gone
        QCOMPARE(m_tabsModel->tabs(), QVector<TabState>({TabState("about:blank", false), TabState("third", false)}));
    }

    void testSetTab() {
        m_tabsModel->setTab(0, QLatin1String("https://debian.org"));
        QCOMPARE(m_tabsModel->tabs(), QVector<TabState>({TabState("https://debian.org", false), TabState("third", false)}));
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
