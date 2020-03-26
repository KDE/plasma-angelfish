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

import QtQuick 2.1
import QtWebEngine 1.6
import QtQuick.Window 2.3
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0 as QtSettings

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mobile.angelfish 1.0

import QtQuick.Layouts 1.2

Kirigami.ApplicationWindow {
    id: webBrowser
    title: webView.title

    // Pointer to the currently active list of tabs.
    //
    // As there are private and normal tabs, switch between
    // them according to the current mode.
    property ListWebView tabs: rootPage.privateMode ? privateTabs : regularTabs

    property WebView currentWebView: webView

    // Pointer to browser settings
    property Settings settings: settings

    // Used to determine if the window is in landscape mode
    property bool landscape: width > height

    property int borderWidth: Math.round(Kirigami.Units.gridUnit / 18);
    property color borderColor: Kirigami.Theme.highlightColor;

    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 30

    pageStack.globalToolBar.showNavigationButtons: false

    // Main Page
    pageStack.initialPage: Kirigami.Page {
        id: rootPage
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
        Kirigami.ColumnView.fillWidth: true
        Kirigami.ColumnView.pinned: true
        Kirigami.ColumnView.preventStealing: true

        // Required to enforce active tab reload
        // on start. As a result, mixed isMobile
        // tabs will work correctly
        property bool initialized: false

        //FIXME: WebView assumes a multi tab ui, will probably need own implementation
        WebAppView {
            id: webView
            anchors.fill: parent
            url: BrowserManager.initialUrl
        }
        ErrorHandler {
            id: errorHandler

            errorString: webView.errorString
            errorCode: webView.errorCode

            anchors.fill: parent
            visible: webView.errorCode !== ""
        }

        Loader {
            id: questionLoader

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

        // Container for the progress bar
        Item {
            id: progressItem

            height: Math.round(Kirigami.Units.gridUnit / 6)
            z: 99
            anchors {
                bottom: parent.bottom
                bottomMargin: -Math.round(height / 2)
                left: tabs.left
                right: tabs.right
            }

            opacity: webView.loading ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad; } }

            Rectangle {
                color: Kirigami.Theme.highlightColor

                width: Math.round((webView.loadProgress / 100) * parent.width)
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
            }
        }

        Loader {
            id: sheetLoader
        }

        // dealing with hiding and showing navigation bar
        property point oldScrollPosition: Qt.point(0, 0)
    }

    Connections {
        target: webBrowser.pageStack
        onCurrentIndexChanged: {
            // drop all sub pages as soon as the browser window is the
            // focussed one
            if (webBrowser.pageStack.currentIndex === 0)
                popSubPages();
        }
    }

    QtSettings.Settings {
        // kept separate to simplify definition of aliases
        property alias x: webBrowser.x
        property alias y: webBrowser.y
        property alias width: webBrowser.width
        property alias height: webBrowser.height
    }

    Settings {
        id: settings
    }

    Component.onCompleted: rootPage.initialized = true

    function popSubPages() {
        while (webBrowser.pageStack.depth > 1)
            webBrowser.pageStack.pop();
    }
}
