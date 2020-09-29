/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.5 as Kirigami

Kirigami.SwipeListItem {
    id: urlDelegate

    property bool showRemove: true

    property string highlightText
    property var regex: new RegExp(highlightText, 'i')
    property string highlightedText: "<b><font color=\"" + Kirigami.Theme.selectionTextColor + "\">$&</font></b>"

    height: Kirigami.Units.gridUnit * 3

    Kirigami.Theme.colorSet: Kirigami.Theme.View

    onClicked: {
        currentWebView.url = url;
    }

    signal removed

    RowLayout {
        Kirigami.Theme.inherit: true

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

                source: model && model.icon ? model.icon : ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            // title
            Controls.Label {
                text: title ? (highlightText ? title.replace(regex, highlightedText) : title) : ""
                elide: Qt.ElideRight
                maximumLineCount: 1
                Layout.fillWidth: true
            }

            // url
            Controls.Label {
                text: url ? (highlightText ? url.replace(regex, highlightedText) : url) : ""
                opacity: 0.6
                elide: Qt.ElideRight
                maximumLineCount: 1
                Layout.fillWidth: true
            }
        }
    }

    actions: [
        Kirigami.Action {
            icon.name: "list-remove"
            visible: urlDelegate.showRemove
            onTriggered: urlDelegate.removed();
        }
    ]
}
