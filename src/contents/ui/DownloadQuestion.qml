import QtQuick 2.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.InlineMessage {
    id: downloadQuestion
    text: i18n("Do you want to download this file?")
    showCloseButton: false

    property var download

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
