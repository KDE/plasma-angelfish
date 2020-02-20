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

import org.kde.kirigami 2.5 as Kirigami
import org.kde.mobile.angelfish 1.0

Item {
    id: navigation

    anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
    }
    height: expandedHeight

    property bool navigationShown: true

    property int expandedHeight: Kirigami.Units.gridUnit * 3
    property int buttonSize: Kirigami.Units.gridUnit * 2

    signal activateUrlEntry;

    Rectangle { anchors.fill: parent; color: Kirigami.Theme.backgroundColor; }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.gridUnit / 2
        anchors.rightMargin: Kirigami.Units.gridUnit / 2

        spacing: Kirigami.Units.smallSpacing
        Kirigami.Theme.inherit: true

        Controls.ToolButton {
            icon.name: "open-menu-symbolic"

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            Kirigami.Theme.inherit: true

            onClicked: globalDrawer.open()
        }

        Controls.ToolButton {
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            Rectangle {
                anchors.centerIn: parent
                height: Kirigami.Units.gridUnit * 1.25
                width: Kirigami.Units.gridUnit * 1.25

                color: "transparent"
                border.color: Kirigami.Theme.textColor
                border.width: Kirigami.Units.gridUnit/10
                radius: Kirigami.Units.gridUnit/5

                Kirigami.Theme.inherit: true

                Controls.Label {
                    anchors.centerIn: parent
                    height: Kirigami.Units.gridUnit
                    width: Kirigami.Units.gridUnit
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 0
                    minimumPointSize: 0
                    clip: true
                    text: "%1".arg(tabs.count)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Kirigami.Theme.inherit: true
                }
            }

            onClicked: pageStack.push(Qt.resolvedUrl("Tabs.qml"))
        }

        Controls.ToolButton {
            id: backButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoBack && !Kirigami.Settings.isMobile
            icon.name: "go-previous"

            Kirigami.Theme.inherit: true

            onClicked: currentWebView.goBack()
        }

        Controls.ToolButton {
            id: forwardButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoForward && !Kirigami.Settings.isMobile
            icon.name: "go-next"

            Kirigami.Theme.inherit: true

            onClicked: currentWebView.goForward()
        }

        Controls.ToolButton {
            id: labelItem
            Layout.fillWidth: true
            Layout.preferredHeight: buttonSize

            property string scheme: UrlUtils.urlScheme(currentWebView.requestedUrl)

            Controls.ToolButton {
                id: schemeIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                icon.name: {
                    if (labelItem.scheme === "https") return "lock";
                    if (labelItem.scheme === "http") return "unlock";
                    return "";
                }
                visible: icon.name
                height: buttonSize * 0.75
                width: visible ? buttonSize * 0.75 : 0
                Kirigami.Theme.inherit: true
                background: Rectangle {
                    implicitWidth: schemeIcon.width
                    implicitHeight: schemeIcon.height
                    color: "transparent"
                }
                onClicked: activateUrlEntry()
            }

            Controls.Label {
                anchors.left: schemeIcon.right
                anchors.right: parent.right
                anchors.top: parent.top
                height: parent.height

                text: {
                    if (labelItem.scheme === "http" || labelItem.scheme === "https") {
                        var h = UrlUtils.urlHostPort(currentWebView.requestedUrl);
                        var p = UrlUtils.urlPath(currentWebView.requestedUrl);
                        if (p === "/") p = ""
                        return '%1<font size="2">%2</font>'.arg(h).arg(p);
                    }
                    return currentWebView.requestedUrl;
                }
                textFormat: Text.StyledText
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                Kirigami.Theme.inherit: true
            }

            onClicked: activateUrlEntry()
        }

        Controls.ToolButton {
            id: reloadButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: !Kirigami.Settings.isMobile
            icon.name: currentWebView.loading ? "process-stop" : "view-refresh"

            Kirigami.Theme.inherit: true

            onClicked: currentWebView.loading ? currentWebView.stop() : currentWebView.reload()

        }

        Controls.ToolButton {
            id: optionsButton

            property string targetState: "overview"

            Layout.fillWidth: false
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            icon.name: "overflow-menu"

            Kirigami.Theme.inherit: true

            onClicked: contextDrawer.open()
        }
    }

    states: [
        State {
            name: "shown"
            when: navigationShown
            AnchorChanges {
                target: navigation
                anchors.bottom: navigation.parent.bottom
                anchors.top: undefined
            }
        },
        State {
            name: "hidden"
            when: !navigationShown
            AnchorChanges {
                target: navigation
                anchors.bottom: undefined
                anchors.top: parent.bottom
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: Kirigami.Units.longDuration; }
    }
}
