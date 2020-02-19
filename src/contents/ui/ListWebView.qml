/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
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
    property var currentItem

    property alias tabsModel: tabsModel

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

        property bool showView: index === tabs.currentIndex

        visible: showView && tabs.activeTabs
        x: 0

        onShowViewChanged: {
            if (showView) {
                tabs.currentItem = webView
            }
        }

        onRequestedUrlChanged: tabsModel.setUrl(index, requestedUrl)

        Component.onCompleted: url = model.pageurl

        Connections {
            target: webView.userAgent
            onUserAgentChanged: {
                tabsModel.setIsMobile(index, webView.userAgent.isMobile);
            }
        }

        Connections {
            target: tabs.model
            onLoadTabsModel: url = model.pageurl
        }
    }
}
