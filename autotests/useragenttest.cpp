/*
 *  SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
 *
 *  SPDX-License-Identifier: LGPL-2.0-only
 */

#include <QtTest/QTest>

#include <QSignalSpy>
#include <QtWebEngine/QtWebEngineVersion>

#include "useragent.h"

class UserAgentTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase()
    {
        m_userAgent = new UserAgent();
    }

    void cleanupTestCase()
    {
        delete m_userAgent;
    }

    void desktopUserAgent()
    {
        m_userAgent->setIsMobile(false);
        const QString expectedString =
                QString("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) "
                        "QtWebEngine/%1 Chrome/75.0.3770.116 Desktop Safari/537.36")
                        .arg(QTWEBENGINE_VERSION_STR);

        QCOMPARE(m_userAgent->userAgent(), expectedString);
    }

    void userAgentChanged()
    {
        QSignalSpy spy(m_userAgent, &UserAgent::userAgentChanged);
        m_userAgent->setIsMobile(true);
        QCOMPARE(spy.count(), 1);
    }

    void mobileUserAgent()
    {
        m_userAgent->setIsMobile(true);
        const QString expectedString =
                QString("Mozilla/5.0 (Linux; Plasma Mobile, like Android 9.0) AppleWebKit/537.36 "
                        "(KHTML, like Gecko) QtWebEngine/%1 Chrome/75.0.3770.116 Mobile "
                        "Safari/537.36")
                        .arg(QTWEBENGINE_VERSION_STR);

        QCOMPARE(m_userAgent->userAgent(), expectedString);
    }

    void setIsMobile()
    {
        QSignalSpy spy(m_userAgent, &UserAgent::isMobileChanged);
        m_userAgent->setIsMobile(false);
        QCOMPARE(spy.count(), 1);
        m_userAgent->setIsMobile(true);
        QCOMPARE(spy.count(), 2);
    }

    void isMobile()
    {
        m_userAgent->setIsMobile(false);
        QCOMPARE(m_userAgent->isMobile(), false);
        m_userAgent->setIsMobile(true);
        QCOMPARE(m_userAgent->isMobile(), true);
    }

private:
    UserAgent *m_userAgent;
};

QTEST_GUILESS_MAIN(UserAgentTest);

#include "useragenttest.moc"
