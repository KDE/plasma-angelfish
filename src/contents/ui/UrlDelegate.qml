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
                text: title ? title.replace(regex, highlightedText) : ""
                elide: Qt.ElideRight
                maximumLineCount: 1
                Layout.fillWidth: true
            }

            // url
            Controls.Label {
                text: url ? url.replace(regex, highlightedText) : ""
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
