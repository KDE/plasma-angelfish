import QtQuick 2.0
import org.kde.kirigami 2.4 as Kirigami

import QtWebEngine 1.1

Kirigami.InlineMessage {
    id: downloadQuestion
    text: i18n("Do you want to download this file?")
    showCloseButton: false

    property WebEngineDownloadItem download

    actions: [
        Kirigami.Action {
            iconName: "download"
            text: i18n("Download")
            onTriggered: {
                downloadQuestion.download.resume()
                downloadQuestion.visible = false
            }
        },
        Kirigami.Action {
            icon.name: "dialog-cancel"
            text: i18n("Cancel")
            onTriggered: {
                downloadQuestion.download.cancel()
                downloadQuestion.visible = false
            }
        }
    ]
}
