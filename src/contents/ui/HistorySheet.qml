/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2019 Simon Schmeisser <s.schmeisser@gmx.net>  *
 *   SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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
