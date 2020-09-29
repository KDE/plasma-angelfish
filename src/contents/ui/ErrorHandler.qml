/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.0 as Kirigami


Item {
    id: errorHandler

    signal refreshRequested

    property string errorCode: ""
    property alias errorString: errorDescription.text

    Behavior on height { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad} }

    Rectangle { anchors.fill: parent; color: Kirigami.Theme.viewBackgroundColor; }

    ColumnLayout {
        spacing: Kirigami.Units.gridUnit
        anchors {
            fill: parent
            margins: Kirigami.Units.gridUnit
        }
        Kirigami.Heading {
            opacity: 0.3
            text: errorCode
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
        Controls.ToolButton {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Retry")
            icon.name: "view-refresh"
            onClicked: errorHandler.refreshRequested()
        }
    }
}
