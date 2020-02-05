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
import QtQuick.Controls 2.0 as Controls
import QtGraphicalEffects 1.0

//import QtWebEngine 1.0

import QtQuick.Layouts 1.0

import org.kde.kirigami 2.7 as Kirigami
// import org.kde.plasma.components 2.0 as PlasmaComponents
// import org.kde.plasma.extras 2.0 as PlasmaExtras


Kirigami.ScrollablePage {
    id: tabsRoot
    title: i18n("Tabs")

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    Kirigami.ColumnView.fillWidth: false

    actions.main: Kirigami.Action {
        icon.name: "list-add"
        text: i18n("New")
        onTriggered: {
            tabs.newTab(browserManager.homepage)
            tabs.currentIndex = tabs.count - 1;
            pageStack.pop()
        }
    }

    property int  itemHeight: Kirigami.Units.gridUnit * 6
    property int  itemWidth: {
        if (!landscapeMode) return width;
        var n = Math.floor( (width - Kirigami.Units.largeSpacing) / (landscapeMinWidth + Kirigami.Units.largeSpacing) );
        return width / n - Kirigami.Units.largeSpacing;
    }
    property int  landscapeMinWidth: Kirigami.Units.gridUnit * 18
    property bool landscapeMode: width > landscapeMinWidth*2 + 3*Kirigami.Units.largeSpacing

    //Rectangle { anchors.fill: parent; color: "brown"; opacity: 0.5; }

    GridView {
        id: grid
        anchors.fill: parent
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.leftMargin: landscapeMode ? Kirigami.Units.largeSpacing/2 : 0 // second half comes from item
        anchors.rightMargin: landscapeMode ? Kirigami.Units.largeSpacing/2 : 0 // second half comes from item
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
                ShaderEffectSource {
                    id: shaderItem

                    //live: true
                    anchors.fill: parent

                    sourceRect: Qt.rect(0, 0, width, height)

                    sourceItem: {
                        tabs.itemAt(index);
                    }
                    //opacity: tabs.currentIndex == index ? 1 : 0.0

                    Behavior on height {
                        SequentialAnimation {
                            ScriptAction {
                                script: {
                                    print("Animation start");
                                    // switch to tabs
                                }
                            }
                            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }
                            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad; target: contentView; property: opacity }
                            ScriptAction {
                                script: {
                                    print("Animation done");
                                    contentView.state = "hidden"
                                }
                            }
                        }
                    }

                    Behavior on width {
                        NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad}

                    }

                    LinearGradient {
                        id: grad
                        anchors.fill: parent
                        cached: true
                        start: Qt.point(0,0)
                        end: Qt.point(0,height)
                        gradient: Gradient {
                            GradientStop { position: Math.max(0.25, 1 - 1.5 * (1 - label.y / itemHeight)); color: "transparent"; }
                            GradientStop { position: Math.max(0.25, label.y / itemHeight); color: Kirigami.Theme.backgroundColor; }
                        }
                    }
                }

                Rectangle {
                    // border around a tile
                    anchors.fill: parent;
                    border.color: Kirigami.Theme.textColor
                    border.width: webBrowser.borderWidth
                    color: "transparent"
                    opacity: tabs.currentIndex === index ? 0.5 : 0.3
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
                    height: Kirigami.gridUnit
                    width: height
                    anchors.right: parent.right
                    anchors.rightMargin: Kirigami.Units.smallSpacing + Kirigami.Units.largeSpacing
                    anchors.top: parent.top
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    onClicked: tabs.closeTab(index)
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
                        elide: Text.ElideRight
                        level: 4
                        text: tabs.itemAt(index) != null ? tabs.itemAt(index).title : ""
                        width: label.width
                    }

                    Controls.Label {
                        elide: Text.ElideRight
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.5
                        text: tabs.itemAt(index) != null ? tabs.itemAt(index).url : ""
                        width: label.width
                    }
                }
            }
        }
    }
}
