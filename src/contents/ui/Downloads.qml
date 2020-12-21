// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.4 as Controls

import QtWebEngine 1.7

import org.kde.kirigami 2.14 as Kirigami
import org.kde.mobile.angelfish 1.0

Kirigami.ScrollablePage {
    title: i18n("Downloads")
    Kirigami.ColumnView.fillWidth: false

    ListView {
        model: DownloadsModel {
            id: downloadsModel
        }
        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            visible: parent.count === 0
            text: i18n("No running downloads")
        }
        delegate: Kirigami.SwipeListItem {
            onClicked: Qt.openUrlExternally(model.downloadedFilePath)
            actions: [
                Kirigami.Action {
                    text: i18n("Cancel")
                    icon.name: model.download.state === WebEngineDownloadItem.DownloadInProgress ? "dialog-cancel" : "list-remove"
                    onTriggered: downloadsModel.removeDownload(index)
                },
                Kirigami.Action {
                    visible: !model.download.isPaused && model.download.state === WebEngineDownloadItem.DownloadInProgress
                    text: i18n("Pause")
                    icon.name: "media-playback-pause"
                    onTriggered: model.download.pause()
                },
                Kirigami.Action {
                    visible: model.download.isPaused && model.download.state === WebEngineDownloadItem.DownloadInProgress
                    text: i18n("Continue")
                    icon.name: "media-playback-start"
                    onTriggered: model.download.resume();
                }

            ]
            RowLayout {
                Kirigami.Icon {
                    source: model.mimeTypeIcon
                    height: Kirigami.Units.iconSizes.medium
                    width: height
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Kirigami.Heading {
                        Layout.fillWidth: true
                        level: 3
                        elide: Qt.ElideRight
                        text: model.fileName
                    }
                    Controls.Label {
                        Layout.fillWidth: true
                        elide: Qt.ElideRight
                        text: model.url
                    }
                    Controls.ProgressBar {
                        Layout.fillWidth: true
                        visible: model.download.state === WebEngineDownloadItem.DownloadInProgress
                        from: 0
                        value: model.download.receivedBytes
                        to: model.download.totalBytes
                    }
                    Controls.Label {
                        visible: model.download.state !== WebEngineDownloadItem.DownloadInProgress
                        text: {
                            switch (model.download.state) {
                            case WebEngineDownloadItem.DownloadRequested:
                                return i18nc("download state", "Starting…");
                            case WebEngineDownloadItem.DownloadCompleted:
                                return i18n("Completed");
                            case WebEngineDownloadItem.DownloadCancelled:
                                return i18n("Cancelled");
                            case WebEngineDownloadItem.DownloadInterrupted:
                                return i18nc("download state", "Interrupted");
                            }
                        }
                    }
                }
            }
        }
    }
}
