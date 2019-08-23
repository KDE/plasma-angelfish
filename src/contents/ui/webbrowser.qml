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

    /**
      * Make loading available to c++
      */
    Component.onCompleted: browserManager.loadUrlRequested.connect(load)

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

        Kirigami.InlineMessage {
            id: newTabQuestion
            type: Kirigami.MessageType.Warning
            text: url? i18n("Site wants to open a new tab: \n%1", url.toString()) : ""
            showCloseButton: true
            anchors.bottom: navigation.top
            anchors.left: parent.left
            anchors.right: parent.right

            property var url

            actions: [
                Kirigami.Action {
                    icon.name: "tab-new"
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
            anchors.bottom: navigation.top
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
                    icon.name: "dialog-cancel"
                    text: i18n("Cancel")
                    onTriggered: {
                        downloadQuestion.download.cancel()
                        downloadQuestion.visible = false
                    }
                }
            ]
        }

        Kirigami.InlineMessage {
            property int permission
            property string origin

            id: permissionQuestion
            text: {
                var text = ""
                if (permission === WebEngineView.Geolocation)
                    text = i18n("Do you want to allow the website to access the geo location?")
                else if (permission === WebEngineView.MediaAudioCapture)
                    text = i18n("Do you want to allow the website to access the microphone?")
                else if (permission === WebEngineView.MediaVideoCapture)
                    text = i18n("Do you want to allow the website to access the camera?")
                else if (permission === WebEngineView.MediaAudioVideoCapture)
                    text = i18n("Do you want to allow the website to access the camera and the microphone?")

                text
            }
            showCloseButton: false
            anchors.bottom: navigation.top
            anchors.left: parent.left
            anchors.right: parent.right

            actions: [
                Kirigami.Action {
                    icon.name: "dialog-ok-apply"
                    text: i18n("Accept")
                    onTriggered: {
                        currentWebView.grantFeaturePermission(permissionQuestion.origin, permissionQuestion.permission, true)
                        permissionQuestion.visible = false
                    }
                },
                Kirigami.Action {
                    icon.name: "dialog-cancel"
                    text: i18n("Decline")
                    onTriggered: {
                        currentWebView.grantFeaturePermission(permissionQuestion.origin, permissionQuestion.permission, false)
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

        InputSheet {
            id: findSheet
            title: i18n("Find in page")
            placeholderText: i18n("Find...")
            description: i18n("Highlight text on the current website")
            onAccepted: currentWebView.findText(findSheet.text)
        }

        ShareSheet {
            id: shareSheet
        }

        Kirigami.ContextDrawer {
            id: contextDrawer

            handleVisible: false
        }

        // The menu at the top right
        contextualActions: [
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
                icon.name: "edit-find"
                onTriggered: findSheet.open()
                text: i18n("Find in page")
            },
            Kirigami.Action {
                icon.name: "configure"
                text: i18n("Settings")
                onTriggered: {
                    pageStack.layers.push("Settings.qml")
                }
            },
            Kirigami.Action {
                icon.name: "document-share"
                text: i18n("Share page")
                onTriggered: {
                    shareSheet.url = currentWebView.url
                    shareSheet.title = currentWebView.title
                    shareSheet.open()
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
            model: urlFilter
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
