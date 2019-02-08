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
//import QtWebEngine 1.0
//import QtQuick.Controls 1.0
//import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
//import QtQuick.Window 2.1
//import QtQuick.Controls.Private 1.0
import org.kde.kirigami 2.0 as Kirigami


Rectangle {
    id: options

    state: "hidden"
    //state: "bookmarks"
    color: Kirigami.Theme.backgroundColor

    property string title: ""

    property int expandedWidth: Kirigami.Units.gridUnit * 14

    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration/2; easing.type: Easing.InOutQuad} }
    Behavior on x { NumberAnimation { duration: Kirigami.Units.longDuration/2; easing.type: Easing.InOutQuad} }

    width: expandedWidth
    height: childrenRect.height

    Rectangle {
        width: webBrowser.borderWidth
        color: webBrowser.borderColor
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    Rectangle {
        height: webBrowser.borderWidth
        color: webBrowser.borderColor
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
    }

    ColumnLayout {
        spacing: 0
        anchors {
            //fill: parent
            top: parent.top
            //topMargin: Kirigami.Units.gridUnit
            left: parent.left
            right: parent.right
            //margins: Kirigami.Units.gridUnit / 2
        }

        OptionsOverview {
            Layout.fillWidth: true;
        }
        Loader {
            id: loader
            Layout.fillHeight: true
            Layout.fillWidth: true
            //Rectangle { anchors.fill: parent; color: "black"; opacity: 0.1; }
        }
    }
    states: [
        State {
            name: "hidden"
            PropertyChanges { target: options; opacity: 0.0}
            PropertyChanges { target: options; x: webBrowser.width}
        },
        State {
            name: "overview"
            PropertyChanges { target: options; title: ""}
            //PropertyChanges { target: options; height: Kirigami.Units.gridUnit * 3}
            PropertyChanges { target: options; opacity: 1.0}
            PropertyChanges { target: options; x: webBrowser.width - options.width }

        }
    ]
}
