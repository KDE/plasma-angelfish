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

    // property int itemHeight: Math.round(itemWidth/ 3 * 2)
    // property int itemWidth: Kirigami.Units.gridUnit * 9
    property int itemHeight: Kirigami.Units.gridUnit * 6
    property int itemWidth: width

    //Rectangle { anchors.fill: parent; color: "brown"; opacity: 0.5; }

    GridView {
        anchors.fill: parent
        model: tabs.model
        cellWidth: itemWidth
        cellHeight: itemHeight

        delegate: Item {
            id: tabItem
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
                        GradientStop { position: 0.0; color: "transparent"; }
                        GradientStop { position: Math.max(0.25, (grad.height - label.x * 4) / grad.height); color: "transparent"; }
                        GradientStop { position: Math.max(0.25, (grad.height - (label.x + label.height) / 2) / grad.height); color: Kirigami.Theme.backgroundColor; }
                        GradientStop { position: 1; color: Kirigami.Theme.backgroundColor; }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    print("Switch from " + tabs.currentIndex + "  to tab " + index);

                    tabs.currentIndex = index;
                    //tabs.positionViewAtIndex(index, ListView.Beginning);
                    //tabs.positionViewAtEnd();
                    pageStack.pop()
                }
            }

            Controls.ToolButton {
                icon.name: "window-close"
                height: Kirigami.gridUnit
                width: height
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.smallSpacing
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing
                onClicked: tabs.closeTab(index)
            }

            Controls.Label {
                id: label
                anchors {
                    left: tabItem.left
                    right: tabItem.right
                    bottom: tabItem.bottom
                    margins: Kirigami.Units.gridUnit * 0.5
                }
                width: itemWidth

                text: tabs.itemAt(index) != null ? tabs.itemAt(index).title : ""
                elide: Qt.ElideRight

            }
        }
    }
}
