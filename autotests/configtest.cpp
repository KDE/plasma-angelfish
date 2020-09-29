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
