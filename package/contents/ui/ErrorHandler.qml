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
import QtQuick.Controls 2.0 as Controls
//import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
//import QtQuick.Window 2.1
//import QtQuick.Controls.Private 1.0

import org.kde.kirigami 2.0 as Kirigami


Item {
    id: errorHandler

    property string errorCode: ""
    property alias errorString: errorDescription.text

    property int expandedHeight: Kirigami.Units.gridUnit * 8

    Behavior on height { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad} }

    Rectangle { anchors.fill: parent; color: theme.backgroundColor; }

    ColumnLayout {

        visible: parent.height > 0
        spacing: Kirigami.Units.gridUnit
        anchors {
            fill: parent
            margins: Kirigami.Units.gridUnit
        }
        Kirigami.Heading {
            level: 3
            Layout.fillHeight: false
            text: i18n("Error loading the page")
        }
        Controls.Label {
            id: errorDescription
            Layout.fillHeight: false
        }
        Item {
            Layout.fillHeight: true
        }
    }

    Controls.Label {
        font.pixelSize: Math.round(parent.height / 3)
        opacity: 0.3
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Kirigami.Units.gridUnit
        }
        text: errorCode
    }

    states: [
        State {
            name: "error"
            when: errorCode != ""
            PropertyChanges { target: errorHandler; height: expandedHeight}
        },
        State {
            name: "normal"
            when: errorCode == ""
            PropertyChanges { target: errorHandler; height: 0}
        }
    ]

}
