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
import QtQuick.Layouts 1.0
//import QtQuick.Window 2.1
//import QtQuick.Controls.Private 1.0
import org.kde.kirigami 2.4 as Kirigami



Controls.ToolButton {
    id: button

    property alias iconSource: iconItem.source

    signal released
    signal pressed
    signal triggered

    Layout.fillWidth: true
    Layout.preferredHeight: buttonSize

    property bool isActive: false
    property bool isPressed: false

    MouseArea {
        id: buttonMouse
        hoverEnabled: true
        anchors.fill: parent
        onPressed: {
            //print("Pressed " + icon)
            isActive = true;
            isPressed = true;
            button.pressed(mouse);
        }
        onReleased: {
            //print("Released TRIGGER!")
            isActive = false;
            isPressed = false;
            //button.clicked(mouse);
            button.triggered(mouse);
        }
        onEntered: {
            //print("Enter")
            //if (buttonMouse.pressed) {
                isActive = true
            //}
        }
        onExited: {
            //print("Enter")
            //if (buttonMouse.pressed) {
                isActive = false
            //}
        }
    }

    Kirigami.Icon {
        id: iconItem
        anchors.fill: parent
        visible: text == ""
    }

    RowLayout {
        id: layoutRow
        anchors.fill: parent
        Kirigami.Icon {
            id: rowIcon
            Layout.preferredWidth: parent.width / 4
            Layout.fillWidth: false
            source: iconItem.source
        }
        visible: text != ""
    }
}
