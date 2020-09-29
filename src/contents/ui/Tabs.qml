/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 2.0 as Controls
import QtGraphicalEffects 1.0

//import QtWebEngine 1.0

import QtQuick.Layouts 1.0

import org.kde.kirigami 2.7 as Kirigami

import org.kde.mobile.angelfish 1.0

Kirigami.ScrollablePage {
    id: tabsRoot
    title: rootPage.privateMode ? i18n("Private Tabs") : i18n("Tabs")

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    Kirigami.ColumnView.fillWidth: false

    actions.main: Kirigami.Action {
        icon.name: "list-add"
        text: i18n("New")
        onTriggered: {
            tabs.tabsModel.newTab("about:blank")
            pageStack.pop()
            urlEntry.open();
        }
    }

    property int  itemHeight: Kirigami.Units.gridUnit * 6
    property int  itemWidth: {
        if (!landscapeMode)
            return width;
        // using grid width to take into account its scrollbar
        const n = Math.floor((grid.width - Kirigami.Units.largeSpacing) / (landscapeMinWidth + Kirigami.Units.largeSpacing));
        return Math.floor(grid.width / n) - Kirigami.Units.largeSpacing;
    }
    property int  landscapeMinWidth: Kirigami.Units.gridUnit * 12
    property bool landscapeMode: grid.width > landscapeMinWidth * 2 + 3 * Kirigami.Units.largeSpacing

    //Rectangle { anchors.fill: parent; color: "brown"; opacity: 0.5; }

    GridView {
        id: grid
        anchors.fill: parent
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.leftMargin: landscapeMode ? Kirigami.Units.largeSpacing / 2 : 0 // second half comes from item
        anchors.rightMargin: landscapeMode ? Kirigami.Units.largeSpacing / 2 : 0 // second half comes from item
        anchors.topMargin: Kirigami.Units.largeSpacing
        model: tabs.model
        cellWidth: itemWidth + (landscapeMode ? Kirigami.Units.largeSpacing : 0)
        cellHeight: itemHeight + Kirigami.Units.largeSpacing

        delegate: Item {
            // taking care of spacing
            width: grid.cellWidth
            height: grid.cellHeight
            Item {
                id: tabItem
                anchors.centerIn: parent
                width: itemWidth
                height: itemHeight

                // ShaderEffectSource requires that corresponding WebEngineView is
                // visible. Here, visibility is enabled while snapshot is taken and
                // removed as soon as it is ready.
                ShaderEffectSource {
                    id: shaderItem

                    live: false
                    anchors.fill: parent
                    sourceRect: Qt.rect(0, 0, sourceItem.width, height/width * sourceItem.width)
                    sourceItem: tabs.itemAt(index)

                    Component.onCompleted: {
                        sourceItem.readyForSnapshot = true;
                        scheduleUpdate();
                    }
                    onScheduledUpdateCompleted: sourceItem.readyForSnapshot = false

                    LinearGradient {
                        id: grad
                        anchors.fill: parent
                        cached: true
                        start: Qt.point(0,0)
                        end: Qt.point(0,height)
                        gradient: Gradient {
                            GradientStop { position: 0.5; color: "transparent"; }
                            GradientStop { position: 1.1; color: "black"; }
                        }
                    }
                }

                Rectangle {
                    // border around a selected tile
                    anchors.fill: parent;
                    border.color: Kirigami.Theme.textColor
                    border.width: webBrowser.borderWidth
                    color: "transparent"
                    opacity: tabs.currentIndex === index ? 1.0 : 0.2
                }

                Rectangle {
                    // selection indicator
                    anchors.fill: parent
                    color: mouse.pressed ? Kirigami.Theme.highlightColor : "transparent"
                    opacity: 0.2
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    onClicked: {
                        print("Switch from " + tabs.currentIndex + "  to tab " + index);

                        tabs.currentIndex = index;
                        pageStack.pop()
                    }
                }

                Controls.ToolButton {
                    icon.name: "window-close"
                    height: Kirigami.Units.gridUnit * 2
                    width: height
                    anchors.right: parent.right
                    anchors.rightMargin: Kirigami.Units.smallSpacing + Kirigami.Units.largeSpacing + (tabsRoot.landscapeMode ? 0 : tabsRoot.width-grid.width)
                    anchors.top: parent.top
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    onClicked: tabs.tabsModel.closeTab(index)
                }

                Column {
                    id: label
                    anchors {
                        left: tabItem.left
                        right: tabItem.right
                        bottom: tabItem.bottom
                        bottomMargin: Kirigami.Units.smallSpacing
                        leftMargin: Kirigami.Units.largeSpacing
                        rightMargin: Kirigami.Units.largeSpacing
                    }
                    spacing: 0

                    Kirigami.Heading {
                        id: heading
                        elide: Text.ElideRight
                        level: 4
                        text: tabs.itemAt(index) ? tabs.itemAt(index).title : ""
                        width: label.width
                        color: "white"
                    }

                    Controls.Label {
                        elide: Text.ElideRight
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.5
                        text: tabs.itemAt(index) ? tabs.itemAt(index).url : ""
                        width: label.width
                        color: "white"
                        visible: heading.text === ""
                    }
                }

                Image {
                    anchors {
                        bottom: tabItem.bottom
                        right: tabItem.right
                        bottomMargin: Kirigami.Units.smallSpacing
                        rightMargin: Kirigami.Units.smallSpacing + Kirigami.Units.largeSpacing + (tabsRoot.landscapeMode ? 0 : tabsRoot.width-grid.width)
                    }
                    fillMode: Image.PreserveAspectFit
                    height: Math.min(sourceSize.height, Kirigami.Units.gridUnit * 2)
                    source: tabs.itemAt(index) ? tabs.itemAt(index).icon : ""
                }
            }
        }

    }

    Component.onCompleted: grid.currentIndex = tabs.currentIndex
}
