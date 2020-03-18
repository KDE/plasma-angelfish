/***************************************************************************
 *                                                                         *
 *   Copyright 2019 Jonah Brüchert                                         *
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

import QtQuick.Controls 2.1 as Controls
import QtQuick.Layouts 1.7
import QtQuick 2.7

import org.kde.kirigami 2.5 as Kirigami

Kirigami.OverlaySheet {
    id: inputSheet
    property string placeholderText
    property string description
    property string title
    property string text

    signal accepted

    function accept() {
        inputSheet.text = sheetTextField.text
        inputSheet.close()
        accepted()
    }

    ColumnLayout {
        Kirigami.Heading {
            text: title
        }

        Controls.Label {
            Layout.fillWidth: true
            text: inputSheet.description
            wrapMode: Text.WordWrap
        }

        Controls.TextField {
            id: sheetTextField
            Layout.fillWidth: true
            placeholderText: inputSheet.placeholderText
            text: inputSheet.text
            focus: true
            onAccepted: accept()
        }

        Controls.Button {
            text: i18n("OK")
            Layout.alignment: Qt.AlignRight
            onClicked: accept()
        }
    }

    onSheetOpenChanged: {
        if (sheetOpen)
            sheetTextField.forceActiveFocus()
    }
}
