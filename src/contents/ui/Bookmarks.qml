/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mobile.angelfish 1.0

Kirigami.ScrollablePage {
    title: i18n("Bookmarks")
    Kirigami.ColumnView.fillWidth: false

    header: Item {
        anchors.horizontalCenter: parent.horizontalCenter
        height: Kirigami.Units.gridUnit * 3
        width: list.width

        Kirigami.SearchField {
            id: search
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit

            clip: true
            inputMethodHints: rootPage.privateMode ? Qt.ImhNoPredictiveText : Qt.ImhNone
            Kirigami.Theme.inherit: true

            onDisplayTextChanged: {
                if (displayText === "" || displayText.length > 2) {
                    list.model.filter = displayText;
                    timer.running = false;
                }
                else timer.running = true;
            }
            Keys.onEscapePressed: pageStack.pop()

            Timer {
                id: timer
                repeat: false
                interval: Math.max(1000, 3000 - search.displayText.length * 1000)
                onTriggered: list.model.filter = search.displayText
            }
        }
    }

    Component {
        id: delegateComponent

        UrlDelegate {
            highlightText: list.model.filter
            onClicked: {
                currentWebView.url = url;
                pageStack.pop();
            }
            onRemoved: BrowserManager.removeBookmark(url);
        }
    }

    ListView {
        id: list
        anchors.fill: parent

        interactive: height < contentHeight
        clip: true

        model: BookmarksHistoryModel {
            bookmarks: true
        }

        delegate: Kirigami.DelegateRecycler {
            width: list.width
            sourceComponent: delegateComponent
        }
    }
}
