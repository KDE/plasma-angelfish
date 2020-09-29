/*
 *  SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 *  SPDX-License-Identifier: LGPL-2.0-only
 */

#include <QTest>

#include "angelfishsettings.h"

class ConfigTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testDefaultValues() {
        QCOMPARE(AngelfishSettings::defaultHomepageValue(), "https://start.duckduckgo.com");
        QCOMPARE(AngelfishSettings::defaultSearchBaseUrlValue(), "https://start.duckduckgo.com/?q=");
        QCOMPARE(AngelfishSettings::defaultWebAutoLoadImagesValue(), true);
        QCOMPARE(AngelfishSettings::defaultWebJavaScriptEnabledValue(), true);
        QCOMPARE(AngelfishSettings::defaultNavBarMainMenuValue(), true);
        QCOMPARE(AngelfishSettings::defaultNavBarTabsValue(), true);
    }

    void testSettingsHelper() {
        qputenv("QT_QUICK_CONTROLS_MOBILE", "true");
        QCOMPARE(SettingsHelper::isMobile(), true);
        QCOMPARE(AngelfishSettings::defaultNavBarBackValue(), false);
        QCOMPARE(AngelfishSettings::defaultNavBarForwardValue(), false);
        QCOMPARE(AngelfishSettings::defaultNavBarReloadValue(), false);
    }
};

QTEST_GUILESS_MAIN(ConfigTest);

#include "configtest.moc"
