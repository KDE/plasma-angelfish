/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Rinigus <rinigus.git@gmail.com>                        *
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
import QtQuick.Controls 2.0 as Controls

import org.kde.kirigami 2.5 as Kirigami
import org.kde.mobile.angelfish 1.0

Item {
    id: findInPage

    anchors {
        top: parent.bottom
        left: parent.left
        right: parent.right
    }
    height: Kirigami.Units.gridUnit * 3

    property bool active: false
    property int  buttonSize: Kirigami.Units.gridUnit * 2

    Rectangle { anchors.fill: parent; color: Kirigami.Theme.backgroundColor; }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.gridUnit / 2
        anchors.rightMargin: Kirigami.Units.gridUnit / 2

        spacing: Kirigami.Units.smallSpacing
        Kirigami.Theme.inherit: true

        Controls.TextField {
            id: input

            Kirigami.Theme.inherit: true
            Layout.fillWidth: true
            leftPadding: index.anchors.rightMargin
            rightPadding: index.width + 2 * index.anchors.rightMargin
            clip: true
            inputMethodHints: rootPage.privateMode ? Qt.ImhNoPredictiveText : Qt.ImhNone
            placeholderText: i18n("Search...")

            onAccepted: currentWebView.findInPageForward(displayText)
            onDisplayTextChanged: currentWebView.findInPageForward(displayText)
            Keys.onEscapePressed: findInPage.active = false

            Controls.Label {
                id: index
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.gridUnit / 2
                anchors.verticalCenter: parent.verticalCenter
                text: "%1 / %2".arg(currentWebView.findInPageResultIndex).arg(currentWebView.findInPageResultCount)
                verticalAlignment: Text.AlignVCenter
                Kirigami.Theme.inherit: true
                color: Kirigami.Theme.disabledTextColor
                visible: input.displayText
            }
        }

        Controls.ToolButton {
            Kirigami.Theme.inherit: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            icon.name: "go-up"

            onClicked: currentWebView.findInPageBack(input.displayText)
        }

        Controls.ToolButton {
            Kirigami.Theme.inherit: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            icon.name: "go-down"

            onClicked: currentWebView.findInPageForward(input.displayText)
        }

        Controls.ToolButton {
            Kirigami.Theme.inherit: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            icon.name: "window-close"
            onClicked: findInPage.active = false
        }
    }

    states: [
        State {
            name: "shown"
            when: findInPage.active
            AnchorChanges {
                target: findInPage
                anchors.bottom: findInPage.parent.bottom
                anchors.top: undefined
            }
        },
        State {
            name: "hidden"
            AnchorChanges {
                target: findInPage
                anchors.bottom: undefined
                anchors.top: findInPage.parent.bottom
            }
        }
    ]

    onActiveChanged: {
        if (!active)
            input.text = '';
        else
            input.forceActiveFocus();
    }

    function activate() {
        active = true;
    }
}
