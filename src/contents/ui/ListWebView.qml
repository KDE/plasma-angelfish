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

    property int currentIndex: -1
    property var currentItem: currentIndex >= 0 && currentIndex < tabsModel.count ? tabs.itemAt(currentIndex) : null

    property int pageHeight: height
    property int pageWidth: width

    property alias count: tabsModel.count

    model: ListModel {
        id: tabsModel
    }

    delegate: WebView {
        id: wv
        anchors.fill: tabs
        url: pageurl;
        visible: index === tabs.currentIndex
        Connections {
            target: tabs
            onCurrentIndexChanged: {
                if (currentIndex===index)
                    tabs.currentItem = wv;
            }
        }
    }

    function createEmptyTab() {
        var t = newTab("");
        return t;
    }

    function newTab(url) {
        tabsModel.append({pageurl: url});
        tabs.currentIndex = tabs.count - 1
    }

    function closeTab(index) {
        tabsModel.remove(index)
        if (tabs.count === 0)
            createEmptyTab()
    }

    Component.onCompleted: {
        newTab("about:blank");
        if (initialUrl) {
            load(initialUrl)
        } else {
            console.log("Using homepage")
            load(browserManager.homepage)
        }
    }
}
