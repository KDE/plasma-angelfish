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

import org.kde.kirigami 2.4 as Kirigami


Kirigami.ApplicationWindow {
    id: webBrowser
    title: "Angelfish Webbrowser"

    /** Pointer to the currently active view.
     *
     * Browser-level functionality should use this to refer to the current
     * view, rather than looking up views in the mode, as far as possible.
     */
    property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.currentItem : null

    onCurrentWebViewChanged: {
        print("Current WebView is now : " + tabs.currentIndex);
    }
    property int borderWidth: Math.round(Kirigami.Units.gridUnit / 18);
    property color borderColor: Kirigami.Theme.highlightColor;

    /**
     * Load a url in the current tab
     */
    function load(url) {
        print("Loading url: " + url);
        currentWebView.url = url;
        currentWebView.forceActiveFocus()
    }

    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 30

    function addHistoryEntry() {
        //print("Adding history");
        var request = new Object;// FIXME
        request.url = currentWebView.url;
        request.title = currentWebView.title;
        request.icon = currentWebView.icon;
        browserManager.addToHistory(request);

    }

    property bool layerShown : pageStack.layers.depth > 1

    pageStack.globalToolBar.style: layerShown ? Kirigami.ApplicationHeaderStyle.Auto : Kirigami.ApplicationHeaderStyle.None

    pageStack.initialPage: Kirigami.Page {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        ListWebView {
            id: tabs
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: navigation.top
            }
        }

        ErrorHandler {
            id: errorHandler

            errorString: currentWebView.errorString
            errorCode: currentWebView.errorCode

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: navigation.top
            }
            visible: currentWebView.errorCode !== ""
        }

        Kirigami.InlineMessage {
            id: newTabQuestion
            type: Kirigami.MessageType.Warning
            text: i18n("Site wants to open a new tab: \n%1", url.toString())
            showCloseButton: true
            anchors.top: navigation.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            property var url

            actions: [
                Kirigami.Action {
                    iconName: "tab-new"
                    text: i18n("Open")
                    onTriggered: {
                        tabs.newTab(newTabQuestion.url.toString())
                        newTabQuestion.visible = false
                    }
                }

            ]
        }

        Kirigami.InlineMessage {
            id: downloadQuestion
            text: i18n("Do you want to download this file?")
            showCloseButton: false
            anchors.top: navigation.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            property var download

            actions: [
                Kirigami.Action {
                    iconName: "download"
                    text: i18n("Download")
                    onTriggered: {
                        downloadQuestion.download.resume()
                        downloadQuestion.visible = false
                    }
                },
                Kirigami.Action {
                    iconName: "dialog-cancel"
                    text: i18n("Cancel")
                    onTriggered: {
                        downloadQuestion.download.cancel()
                        downloadQuestion.visible = false
                    }
                }
            ]
        }

        // Container for the progress bar
        Item {
            id: progressItem

            height: Math.round(Kirigami.Units.gridUnit / 6)
            z: navigation.z + 1
            anchors {
                top: tabs.bottom
                topMargin: -Math.round(height / 2)
                left: tabs.left
                right: tabs.right
            }

            opacity: currentWebView.loading ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad; } }

            Rectangle {
                color: Kirigami.Theme.highlightColor

                width: Math.round((currentWebView.loadProgress / 100) * parent.width)
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
            }

        }

        // When clicked outside the menu, hide it
        MouseArea {
            id: optionsDismisser
            visible: options.state != "hidden"
            onClicked: options.state = "hidden"
            anchors.fill: parent
        }

        // The menu at the top right
        Options {
            id: options

            anchors {
                bottom: navigation.top
            }
        }

        Navigation {
            id: navigation
            navigationShown: !webappcontainer && webBrowser.visibility !== Window.FullScreen

            anchors {
                bottom: completion.top
                left: parent.left
                right: parent.right
            }

            onTextChanged: urlFilter.setFilterFixedString(text)
        }

        Completion {
            id: completion
            model: urlFilter
            width: 0.9 * navigation.width
            height: 0.5 * parent.height
            z: 10
            visible: navigation.textFocus
            searchText: navigation.text

            anchors {
                bottom: parent.bottom
                horizontalCenter: navigation.horizontalCenter
            }
        }

        // Thin line underneath navigation
        Rectangle {
            height: webBrowser.borderWidth
            color: webBrowser.borderColor
            anchors {
                left: parent.left
                bottom: navigation.top
                right: options.left
            }
        }
    }
}
