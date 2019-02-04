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
import QtWebEngine 1.4
import QtQuick.Controls 2.0 as Controls

import org.kde.kirigami 2.0 as Kirigami

import "regex-weburl.js" as RegexWebUrl


Item {
    id: errorHandler

    property string searchUrl: "https://duckduckgo.com/?q="

    property string errorCode: ""

    property bool navigationShown: errorCode != "" || webBrowser.url === "" || true

    property alias textFocus: urlInput.activeFocus
    property alias text: urlInput.text

    property int expandedHeight: Kirigami.Units.gridUnit * 2.5
    property int buttonSize: Kirigami.Units.gridUnit * 2

    Behavior on height { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad} }

    Rectangle { anchors.fill: parent; color: Kirigami.Theme.backgroundColor; }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.gridUnit / 2
        anchors.rightMargin: Kirigami.Units.gridUnit / 2
        visible: navigationShown

        spacing: Kirigami.Units.smallSpacing

        /*
        PlasmaComponents.ToolButton {
            id: backButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoBack
            iconSource: "go-previous"

            onClicked: currentWebView.goBack()
        }

        PlasmaComponents.ToolButton {
            id: forwardButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoForward
            iconSource: "go-next"

            onClicked: currentWebView.goForward()
        }

        PlasmaComponents.ToolButton {
            id: reloadButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            iconSource: currentWebView.loading ? "process-stop" : "view-refresh"

            onClicked: currentWebView.loading ? currentWebView.stop() : currentWebView.reload()

        }
        */

        Controls.TextField {
            id: urlInput

            Layout.fillWidth: true

            text: currentWebView.url

            selectByMouse: true
            focus: false

            onAccepted: {
                if (text.match(RegexWebUrl.re_weburl)) {
                    load(browserManager.urlFromUserInput(text))
                } else {
                    load(browserManager.urlFromUserInput(searchUrl + text))
                }
            }
        }

        Item {
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.loading

            Controls.BusyIndicator {
                width: buttonSize
                height: width
                anchors.centerIn: parent
                running: currentWebView.loading
            }
        }

        OptionButton {
            id: optionsButton

            property string targetState: "overview"

            Layout.fillWidth: false
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            iconSource: "open-menu-symbolic"

            onClicked: options.state = (options.state != "hidden" ? "hidden" : targetState)
        }
    }

    states: [
        State {
            name: "shown"
            when: navigationShown
            PropertyChanges { target: errorHandler; x: -expandedHeight}
        },
        State {
            name: "hidden"
            when: !navigationShown
            PropertyChanges { target: errorHandler; x: 0}
        }
    ]

}
