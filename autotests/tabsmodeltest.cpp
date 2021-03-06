/*
 *  SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 *  SPDX-License-Identifier: LGPL-2.0-only
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
        QCOMPARE(m_tabsModel->tab(0).url(), "about:blank");
    }

    void testNewTab()
    {
        m_tabsModel->newTab("https://kde.org");
        QCOMPARE(m_tabsModel->tabs().count(), 2);

        qDebug() << m_tabsModel->tab(1).url() << m_tabsModel->tab(0).isMobile();
        QCOMPARE(m_tabsModel->tab(1).url(), "https://kde.org");

        // newly created tab should be current tab now
        QCOMPARE(m_tabsModel->currentTab(), 1);
    }

    void testCurrentTab()
    {
        QCOMPARE(m_tabsModel->tabs().at(m_tabsModel->currentTab()).url(), "https://kde.org");
    }

    void testCloseTab() {
        // Close initial tab, keep kde.org one
        m_tabsModel->closeTab(0);
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        // Check tabs moved properly
        QCOMPARE(m_tabsModel->tabs().at(0).url(), "https://kde.org");
    }

    void testLoad() {
        m_tabsModel->setUrl(0, "https://debian.org");

        // Number of tabs must not change
        QCOMPARE(m_tabsModel->tabs().count(), 1);

        QCOMPARE(m_tabsModel->tabs().at(0).url(), "https://debian.org");
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
        QCOMPARE(m_tabsModel->tabs().at(0).url(), "about:blank");

        //
        // Case 2: There are multiple tabs
        //
        m_tabsModel->newTab("second");
        m_tabsModel->newTab("third");

        QCOMPARE(m_tabsModel->tabs(), QVector<TabState>({
            TabState("about:blank", m_tabsModel->isMobileDefault()),
            TabState("second", m_tabsModel->isMobileDefault()),
            TabState("third", m_tabsModel->isMobileDefault())
        }));

        // current tab is 2
        // close tab "second"
        m_tabsModel->closeTab(1);
        // current tab should now be 0, since we reset to first tab if the current tab is closed
        QCOMPARE(m_tabsModel->currentTab(), 0);

        // "second" is indeed gone
        QCOMPARE(m_tabsModel->tabs(), QVector<TabState>({
            TabState("about:blank",  m_tabsModel->isMobileDefault()),
            TabState("third",  m_tabsModel->isMobileDefault())
        }));
    }

    void testSetTab() {
        m_tabsModel->setUrl(0, QStringLiteral("https://debian.org"));
        QCOMPARE(m_tabsModel->tabs(), QVector<TabState>({
            TabState("https://debian.org",  m_tabsModel->isMobileDefault()),
            TabState("third",  m_tabsModel->isMobileDefault())}
        ));
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

QTEST_GUILESS_MAIN(TabsModelTest);

#include "tabsmodeltest.moc"
