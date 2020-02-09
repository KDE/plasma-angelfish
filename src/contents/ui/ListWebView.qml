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
import QtQuick.Controls.Styles 1.0
import QtQml.Models 2.1

import QtWebEngine 1.6


Repeater {
    id: tabs
    clip: true

    property bool activeTabs: true
    property bool privateTabsMode: false

    property int currentIndex: -1
    property var currentItem

    property alias count: tabsModel.count

    model: ListModel {
        id: tabsModel
    }

    delegate: WebView {
        id: wv
        anchors {
            bottom: tabs.bottom
            top: tabs.top
        }
        privateMode: tabs.privateTabsMode
        url: pageurl;
        width: tabs.width

        property bool showView: index === tabs.currentIndex

        visible: showView && tabs.activeTabs
        x: 0

        onShowViewChanged: if (showView) tabs.currentItem = wv
        onUrlChanged: if (!privateTabsMode) browserManager.setTabUrl(index, url)
    }

    function createEmptyTab(front) {
        newTab("about:blank", front);
    }

    function newTab(url, front) {
        var p = {pageurl: url};
        if (front) {
            tabsModel.insert(0, p);
            tabs.currentIndex = 0;
        }
        else {
            tabsModel.append(p);
            tabs.currentIndex = tabs.count - 1;
        }
    }

    function closeTab(index) {
        if (index<0 && index >= tabs.count)
            return; // index out of bounds

        if (tabs.count <= 1) {
            // create new tab before removing the last one
            // to avoid linking all signals to null object
            createEmptyTab(true);
            tabs.currentItem = tabs.itemAt(0);
            index = 1;
        }
        if (tabs.currentIndex === index) {
            // handle the removal of current tab
            tabs.currentIndex = 0;
            tabs.currentItem = tabs.itemAt(0);
        }

        if (!privateTabsMode) browserManager.rmTab(index);
        tabsModel.remove(index);
    }

    Component.onCompleted: {
        if (privateTabsMode)
            createEmptyTab();
        else
            newTab(browserManager.homepage);
        if (initialUrl) {
            load(initialUrl)
        } else {
            console.log("Using homepage")
            load(browserManager.homepage)
        }
    }

    onCurrentIndexChanged: browserManager.setCurrentTab(tabs.currentIndex)
}
