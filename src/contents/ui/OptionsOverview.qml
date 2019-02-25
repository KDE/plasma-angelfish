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
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.0 as Kirigami


ColumnLayout {
    id: optionsOverview

    property int buttonSize: Kirigami.Units.gridUnit * 2

    RowLayout {
        id: layout

        height: buttonSize
        spacing: 0
//         anchors.leftMargin: Kirigami.Units.gridUnit / 2
//         anchors.rightMargin: Kirigami.Units.gridUnit / 2
        //visible: navigationShown

        //spacing: Kirigami.Units.smallSpacing

        OptionButton {
            id: backButton


            enabled: currentWebView.canGoBack
            iconSource: "go-previous"

            onClicked: {
                options.state = "hidden";
                currentWebView.goBack()
            }
        }

        OptionButton {
            id: forwardButton

            enabled: currentWebView.canGoForward
            iconSource: "go-next"

            onClicked: {
                options.state = "hidden";
                currentWebView.goForward()
            }

        }

        OptionButton {
            id: reloadButton

            iconSource: currentWebView.loading ? "process-stop" : "view-refresh"

            onClicked: {
                options.state = "hidden";
                currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
            }

        }

        OptionButton {
            id: bookmarkButton

            iconSource: "bookmarks"

            onClicked: {
                print("Adding bookmark");
                var request = new Object;// FIXME
                request.url = currentWebView.url;
                request.title = currentWebView.title;
                request.icon = currentWebView.icon;
                request.bookmarked = true;
                browserManager.addBookmark(request);
                options.state = "hidden"

            }

        }

    }

    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing
        Layout.fillWidth: true
    }

    OptionButton {
        iconSource: "tab-duplicate"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onClicked: {
            pageStack.layers.push("Tabs.qml")
            options.state = "hidden"
        }
        text: i18n("Tabs")
    }

    OptionButton {
        iconSource: "bookmarks"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onClicked: {
            pageStack.layers.push("Bookmarks.qml")
            options.state = "hidden"
        }
        text: i18n("Bookmarks")
    }

    OptionButton {
        iconSource: "view-history"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onClicked: {
            pageStack.layers.push("History.qml")
            options.state = "hidden"
        }
        text: i18n("History")
    }

    InputSheet {
        id: findSheet
        title: i18n("Find in page")
        placeholderText: i18n("Find...")
        description: i18n("Highlight text on the current website")
        onAccepted: currentWebView.findText(findSheet.text)
    }

    OptionButton {
        iconSource: "edit-find"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onClicked: {
            options.state = "hidden"
            findSheet.open()
        }
        text: i18n("Find in page")
    }

    OptionButton {
        iconSource: "configure"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        text: i18n("Settings")
        onClicked: {
            pageStack.layers.push("Settings.qml")
            options.state = "hidden"
        }
    }

    OptionButton {
        iconSource: "document-share"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        text: i18n("Share page")
        onClicked: {
            shareSheet.url = currentWebView.url
            shareSheet.title = currentWebView.title
            shareSheet.open()
        }
    }

    ShareSheet {
        id: shareSheet
    }
}
