// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.5 as Controls
import org.kde.kirigami 2.12 as Kirigami


import org.kde.mobile.angelfish 1.0

Kirigami.ScrollablePage {
    id: adblockSettings
    enabled: AdblockUrlInterceptor.adblockSupported

    title: i18n("Adblock settings")

    Kirigami.ColumnView.fillWidth: false

    actions.main: Kirigami.Action {
        icon.name: "list-add"
        onTriggered: addSheet.open()
    }

    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing) {
            filterlistModel.refreshLists();
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        visible: !AdblockUrlInterceptor.adblockSupported
        width: parent.width - (Kirigami.Units.largeSpacing * 4)

        text: i18n("The adblock functionality isn't included in this build.")
    }

    Kirigami.OverlaySheet {
        id: addSheet

        header: Kirigami.Heading { text: i18n("Add filterlist") }
        contentItem: ColumnLayout {
            Layout.preferredWidth: adblockSettings.width
            Controls.Label {
                Layout.fillWidth: true
                text: i18n("Name")
            }
            Controls.TextField {
                id: nameInput
                Layout.fillWidth: true
            }

            Controls.Label {
                Layout.fillWidth: true
                text: i18n("Url")
            }
            Controls.TextField {
                id: urlInput
                Layout.fillWidth: true
            }

            Controls.Button {
                Layout.alignment: Qt.AlignRight
                text: i18n("Add")
                onClicked: {
                    filterlistModel.addFilterList(nameInput.text, urlInput.text)
                    adblockSettings.refreshing = true
                    filterlistModel.refreshLists()
                    addSheet.close()
                }
            }
        }
    }

    ListView {
        visible: AdblockUrlInterceptor.adblockSupported
        model: AdblockFilterListsModel {
            id: filterlistModel
            onRefreshFinished: adblockSettings.refreshing = false
        }

        delegate: Kirigami.SwipeListItem {
            id: delegateRoot

            required property string displayName
            required property url url
            required property int index

            ColumnLayout {
                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 3
                    elide: Qt.ElideRight
                    text: delegateRoot.displayName
                }
                Controls.Label {
                    Layout.fillWidth: true
                    elide: Qt.ElideRight
                    text: delegateRoot.url
                }
            }

            text: displayName
            actions: [
                Kirigami.Action {
                    icon.name: "list-remove"
                    text: i18n("Remove this filter list")
                    onTriggered: filterlistModel.removeFilterList(delegateRoot.index)
                }
            ]
        }
    }
}
