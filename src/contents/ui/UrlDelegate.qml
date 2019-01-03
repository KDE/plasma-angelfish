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
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.0 as Kirigami


Controls.ItemDelegate {
    id: urlDelegate

    height: Kirigami.Units.gridUnit * 3
    width: parent.width

    //Rectangle { anchors.fill: parent; color: "white"; opacity: 0.5; }

    onClicked: {
        load(url)
//         tabs.newTab(url)
//         contentView.state = "hidden"
    }

    signal removed

    Kirigami.Icon {
        id: urlIcon

        width: height

        anchors {
            left: parent.left
            top: parent.top
            topMargin: Kirigami.Units.gridUnit / 2
            bottomMargin: Kirigami.Units.gridUnit / 2
            bottom: parent.bottom
            margins: Kirigami.Units.smallSpacing
        }
        source: icon

    }

    Image {
        anchors.fill: urlIcon
        source: preview == undefined ? "" : preview
    }

    Controls.Label {
        id: urlTitle
        text: title
        anchors {
            left: urlIcon.right
            leftMargin: Kirigami.Units.largeSpacing / 2
            right: parent.right
            bottom: parent.verticalCenter
            top: urlIcon.top
            //margins: Kirigami.Units.smallSpacing
        }
    }

    Controls.Label {
        id: urlUrl
        text: url
        opacity: 0.6
        font.pointSize: theme.smallestFont.pointSize
        anchors {
            left: urlIcon.right
            leftMargin: Kirigami.Units.largeSpacing / 2
            right: removeIcon.left
            top: urlIcon.verticalCenter
            bottom: parent.bottom
            //margins: Kirigami.Units.smallSpacing
        }
    }

    Kirigami.Icon {
        id: removeIcon

        width: height
        source: "list-remove"
        //visible: bookmarked

        anchors {
            right: parent.right
            top: parent.top
            topMargin: Kirigami.Units.gridUnit
            bottomMargin: Kirigami.Units.gridUnit
            bottom: parent.bottom
            margins: Kirigami.Units.smallSpacing
        }
        MouseArea {
            anchors.fill: parent
            onClicked: urlDelegate.removed();
        }
    }
}
