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
import org.kde.mobile.angelfish 1.0


Repeater {
    id: tabs
    clip: true

    property bool activeTabs: true
    property bool privateTabsMode: false

    property alias currentIndex: tabsModel.currentTab
    property var currentItem

    property alias tabsModel: tabsModel

    model: TabsModel {
        id: tabsModel
        privateMode: privateTabsMode
    }

    delegate: WebView {
        id: webView
        anchors {
            bottom: tabs.bottom
            top: tabs.top
        }
        privateMode: tabs.privateTabsMode
        url: model.pageurl
        width: tabs.width

        property bool showView: index === tabs.currentIndex

        visible: showView && tabs.activeTabs
        x: 0

        onShowViewChanged: {
            if (showView) {
                tabs.currentItem = webView
            }
        }
        onUrlChanged: {
            tabs.tabsModel.setTab(index, url)
        }
    }

    Component.onCompleted: {
        if (!privateTabsMode && !initialUrl && tabsModel.rowCount() === 1 && tabsModel.tabUrl(0) === "about:blank")
            tabsModel.load(BrowserManager.homepage);
        else if (initialUrl) {
            tabsModel.newTab(initialUrl)
        } else {
            console.log("in private mode, not loading homepage")
        }
    }
}
