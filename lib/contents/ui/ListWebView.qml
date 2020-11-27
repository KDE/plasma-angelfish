/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQml.Models 2.1
import QtWebEngine 1.6

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mobile.angelfish 1.0


Repeater {
    id: tabs
    clip: true

    property bool activeTabs: false
    property bool privateTabsMode: false

    property alias currentIndex: tabsModel.currentTab
    property WebView currentItem

    property alias tabsModel: tabsModel

    property WebEngineProfile profile: AngelfishWebProfile {
        httpUserAgent: tabs.currentItem.userAgent.userAgent
        offTheRecord: tabs.privateTabsMode
        storageName: tabs.privateTabsMode ? "Private" : Settings.profile

        questionLoader: rootPage.questionLoader
    }

    model: TabsModel {
        id: tabsModel
        isMobileDefault: Kirigami.Settings.isMobile
        privateMode: privateTabsMode
        Component.onCompleted: {
            tabsModel.loadInitialTabs();
            loadTabsModel();
        }
        signal loadTabsModel()
    }

    delegate: WebView {
        id: webView
        anchors {
            bottom: tabs.bottom
            top: tabs.top
        }
        privateMode: tabs.privateTabsMode
        userAgent.isMobile: model.isMobile
        width: tabs.width

        profile: tabs.profile

        property bool readyForSnapshot: false
        property bool showView: index === tabs.currentIndex

        visible: (showView || readyForSnapshot || loadingActive) && tabs.activeTabs
        x: showView && tabs.activeTabs ? 0 : -width
        z: showView && tabs.activeTabs ? 0 : -1

        onShowViewChanged: {
            if (showView) {
                tabs.currentItem = webView
            }
        }

        onRequestedUrlChanged: tabsModel.setUrl(index, requestedUrl)

        Component.onCompleted: url = model.pageurl

        Connections {
            target: webView.userAgent
            function onUserAgentChanged() {
                tabsModel.setIsMobile(index, webView.userAgent.isMobile);
            }
        }

        Connections {
            target: tabs.model
            function onLoadTabsModel() {
                url = model.pageurl
            }
        }
    }
}
