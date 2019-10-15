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

import org.kde.kirigami 2.4 as Kirigami
import org.kde.mobile.angelfish 1.0


Kirigami.ApplicationWindow {
    id: webBrowser
    title: i18n("Angelfish Web Browser")

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

    BrowserManager {
        id: browserManager
    }

    /**
      * Make loading available to c++
      */
    Connections {
        target: browserManager
        onLoadUrlRequested: {
            load(url)
        }
    }

    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 30

    /**
      * Add page of currently active webview to history
      */
    function addHistoryEntry() {
        //print("Adding history");
        var request = new Object;// FIXME
        request.url = currentWebView.url;
        request.title = currentWebView.title;
        request.icon = currentWebView.icon;
        browserManager.addToHistory(request);
    }

    // Only show ToolBar if a layer is open
    property bool layerShown : pageStack.layers.depth > 1
    pageStack.globalToolBar.style: layerShown ? Kirigami.ApplicationHeaderStyle.Auto : Kirigami.ApplicationHeaderStyle.None

    globalDrawer: Kirigami.GlobalDrawer {
        id: globalDrawer

        handleVisible: false

        actions: [
            Kirigami.Action {
                icon.name: "tab-duplicate"
                onTriggered: {
                    pageStack.layers.push("Tabs.qml")
                }
                text: i18n("Tabs")
            },
            Kirigami.Action {
                icon.name: "view-private"
                onTriggered: {
                    rootPage.privateMode ? rootPage.privateMode = false : rootPage.privateMode = true
                }
                text: rootPage.privateMode ? i18n("Leave private mode") : i18n("Private mode")
            },
            Kirigami.Action {
                icon.name: "bookmarks"
                onTriggered: {
                    pageStack.layers.push("Bookmarks.qml")
                }
                text: i18n("Bookmarks")
            },
            Kirigami.Action {
                icon.name: "view-history"
                onTriggered: {
                    pageStack.layers.push("History.qml")
                }
                text: i18n("History")
            },
            Kirigami.Action {
                icon.name: "configure"
                text: i18n("Settings")
                onTriggered: {
                    pageStack.layers.push("Settings.qml")
                }
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer

        handleVisible: false
    }

    // Main Page
    pageStack.initialPage: Kirigami.Page {
        id: rootPage
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        property bool privateMode: false

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

        Loader {
            id: questionLoader

            anchors.bottom: navigation.top
            anchors.left: parent.left
            anchors.right: parent.right
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

        Loader {
            id: sheetLoader
        }

        // The menu at the bottom right
        contextualActions: [
            Kirigami.Action {
                icon.name: "edit-find"
                onTriggered: {
                    sheetLoader.setSource("FindInPageSheet.qml")
                    sheetLoader.item.open()
                }
                text: i18n("Find in page")
            },
            Kirigami.Action {
                icon.name: "document-share"
                text: i18n("Share page")
                onTriggered: {
                    sheetLoader.setSource("ShareSheet.qml")
                    sheetLoader.item.url = currentWebView.url
                    sheetLoader.item.title = currentWebView.title
                    sheetLoader.item.open()
                }
            },
            Kirigami.Action {
                enabled: currentWebView.canGoBack
                icon.name: "go-previous"
                text: i18n("Go previous")

                onTriggered: {
                    currentWebView.goBack()
                }
            },
            Kirigami.Action {
                enabled: currentWebView.canGoForward
                icon.name: "go-next"
                text: i18n("Go forward")


                onTriggered: {
                    currentWebView.goForward()
                }
            },
            Kirigami.Action {
                icon.name: currentWebView.loading ? "process-stop" : "view-refresh"
                text: currentWebView.loading ? i18n("Stop loading") : i18n("Refresh")

                onTriggered: {
                    currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                }
            },
            Kirigami.Action {
                icon.name: "bookmarks"
                text: i18n("Add bookmark")

                onTriggered: {
                    print("Adding bookmark");
                    var request = new Object;// FIXME
                    request.url = currentWebView.url;
                    request.title = currentWebView.title;
                    request.icon = currentWebView.icon;
                    request.bookmarked = true;
                    browserManager.addBookmark(request);
                }
            }
        ]

        // Bottom navigation bar
        Navigation {
            id: navigation
            navigationShown: !webappcontainer && webBrowser.visibility !== Window.FullScreen

            Kirigami.Theme.colorSet: rootPage.privateMode ? Kirigami.Theme.Complementary : Kirigami.Theme.Window

            layer.enabled: navigation.visible
            layer.effect: DropShadow {
                verticalOffset: - 1
                color: Kirigami.Theme.disabledTextColor
                samples: 10
                spread: 0.1
                cached: true // element is static
            }

            anchors {
                bottom: completion.top
                left: parent.left
                right: parent.right
            }

            onTextChanged: urlFilter.setFilterFixedString(text)
        }

        Completion {
            id: completion
            model: UrlFilterProxyModel {
                id: urlFilter
                sourceModel: browserManager.history
            }
            width: parent.width
            height: 0.5 * parent.height
            visible: navigation.textFocus
            searchText: navigation.text

            Behavior on height {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration * 2
                }
            }

            anchors {
                bottom: parent.bottom
                horizontalCenter: navigation.horizontalCenter
            }
        }

        // Thin line above navigation
        Rectangle {
            height: webBrowser.borderWidth
            color: webBrowser.borderColor
            anchors {
                left: parent.left
                bottom: navigation.top
                right: parent.right
            }
        }
    }
}
