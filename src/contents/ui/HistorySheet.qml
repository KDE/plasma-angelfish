/***************************************************************************
 *                                                                         *
 *   Copyright 2019 Simon Schmeisser <s.schmeisser@gmx.net>                *
 *   Copyright 2019 Jonah Brüchert <jbb@kaidan.im>                         *
 *   Copyright 2020 Rinigus <rinigus.git@gmail.com>                        *
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

Controls.Drawer {
    id: overlay
    dragMargin: 0
    edge: Qt.BottomEdge
    width: parent.width

    property bool backHistory: true

    property int itemHeight: Kirigami.Units.gridUnit * 3

    property int fullHeight: Math.min(Math.max(itemHeight * 1, listView.contentHeight) + itemHeight,
                                      0.9 * rootPage.height)

    contentHeight: fullHeight
    contentWidth: parent.width
    contentItem: ListView {
        id: listView
        anchors.fill: parent

        boundsBehavior: Flickable.StopAtBounds
        clip: true

        delegate: UrlDelegate {
            showRemove: false
            onClicked: {
                currentWebView.goBackOrForward(model.offset);
                overlay.close();
            }
        }

        model: overlay.backHistory ? currentWebView.navigationHistory.backItems :
                                     currentWebView.navigationHistory.forwardItems
    }

    onClosed: {
        currentWebView.forceActiveFocus();
    }
}
