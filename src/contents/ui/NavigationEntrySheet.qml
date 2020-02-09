/***************************************************************************
 *                                                                         *
 *   Copyright 2019 Simon Schmeisser <s.schmeisser@gmx.net>                *
 *   Copyright 2019 Jonah Brüchert <jbb@kaidan.im>                         *
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

import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.5 as Kirigami
import org.kde.mobile.angelfish 1.0

import "regex-weburl.js" as RegexWebUrl

Kirigami.OverlaySheet {
    id: overlay
    showCloseButton: false

    property int buttonSize: Kirigami.Units.gridUnit * 2

    header: RowLayout {
        id: editRow
        Layout.fillWidth: true

        Controls.ToolButton {
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            icon.name: "window-minimize"

            Kirigami.Theme.inherit: true

            onClicked: overlay.close()
        }

        Controls.TextField {
            id: urlInput

            Layout.fillWidth: true

            text: currentWebView.url

            selectByMouse: true
            focus: false

            Kirigami.Theme.inherit: true

            onAccepted: applyUrl()
            onTextChanged: urlFilter.setFilterFixedString(text)
            Keys.onEscapePressed: if (overlay.sheetOpen) overlay.close()

            function applyUrl() {
                if (text.match(RegexWebUrl.re_weburl)) {
                    load(browserManager.urlFromUserInput(text))
                } else {
                    load(browserManager.urlFromUserInput(browserManager.searchBaseUrl + text))
                }
                overlay.close();
            }
        }

        Controls.ToolButton {
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            icon.name: "go-next"

            Kirigami.Theme.inherit: true

            onClicked: urlInput.applyUrl();
        }
    }

    ListView {
        id: listView
        clip: true
        implicitWidth: parent.width

        delegate: UrlDelegate {
            showRemove: false
            onClicked: overlay.close()
            highlightText: urlInput.text
        }

        model: UrlFilterProxyModel {
            id: urlFilter
            sourceModel: browserManager.history
        }

        footer: Item {
            // ensure that it covers most of the window
            // even if there is nothing to show in the list
            width: listView.width
            height: rootPage.height*0.9 - editRow.height
        }
    }

    onSheetOpenChanged: {
        if (sheetOpen) {
            urlInput.text = currentWebView.url;
            urlInput.selectAll();
            urlInput.forceActiveFocus();
            listView.positionViewAtBeginning();
        }
        else {
            currentWebView.forceActiveFocus();
        }
    }
}
