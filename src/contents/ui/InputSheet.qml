/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2019 Jonah Brüchert                           *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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

    header: Kirigami.Heading {
        text: title
    }

    ColumnLayout {
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
        if (sheetOpen) {
            sheetTextField.forceActiveFocus()
        }
    }
}
