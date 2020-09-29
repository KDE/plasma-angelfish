/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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
            id: mainMenuButton
            icon.name: rootPage.privateMode ? "view-private" : "open-menu-symbolic"
            visible: webBrowser.landscape || Settings.navBarMainMenu

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            Kirigami.Theme.inherit: true

            onClicked: globalDrawer.open()
        }

        Controls.ToolButton {
            visible: webBrowser.landscape || Settings.navBarTabs
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            Rectangle {
                anchors.centerIn: parent
                height: Kirigami.Units.gridUnit * 1.25
                width: Kirigami.Units.gridUnit * 1.25

                color: "transparent"
                border.color: Kirigami.Theme.textColor
                border.width: Kirigami.Units.gridUnit / 10
                radius: Kirigami.Units.gridUnit / 5

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

            visible: currentWebView.canGoBack && Settings.navBarBack
            icon.name: "go-previous"

            Kirigami.Theme.inherit: true

            onClicked: currentWebView.goBack()
            onPressAndHold: {
                historySheet.backHistory = true;
                historySheet.open();
            }
        }

        Controls.ToolButton {
            id: forwardButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoForward && Settings.navBarForward
            icon.name: "go-next"

            Kirigami.Theme.inherit: true

            onClicked: currentWebView.goForward()
            onPressAndHold: {
                historySheet.backHistory = false;
                historySheet.open();
            }
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
                        return UrlUtils.htmlFormattedUrl(currentWebView.requestedUrl)
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

            visible: Settings.navBarReload
            icon.name: currentWebView.loading ? "process-stop" : "view-refresh"

            Kirigami.Theme.inherit: true

            onClicked: currentWebView.loading ? currentWebView.stopLoading() : currentWebView.reload()

        }

        Controls.ToolButton {
            id: optionsButton

            property string targetState: "overview"

            Layout.fillWidth: false
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: webBrowser.landscape || Settings.navBarContextMenu
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
                anchors.top: navigation.parent.bottom
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation {
            duration: navigation.visible ? Kirigami.Units.longDuration : 0
        }
    }
}
