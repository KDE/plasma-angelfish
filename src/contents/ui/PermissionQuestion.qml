import org.kde.kirigami 2.4 as Kirigami
import QtWebEngine 1.5

Kirigami.InlineMessage {
    property int permission
    property string origin

    id: permissionQuestion
    text: {
        if (permission === WebEngineView.Geolocation)
            i18n("Do you want to allow the website to access the geo location?")
        else if (permission === WebEngineView.MediaAudioCapture)
            i18n("Do you want to allow the website to access the microphone?")
        else if (permission === WebEngineView.MediaVideoCapture)
            i18n("Do you want to allow the website to access the camera?")
        else if (permission === WebEngineView.MediaAudioVideoCapture)
            i18n("Do you want to allow the website to access the camera and the microphone?")
    }
    showCloseButton: false

    actions: [
        Kirigami.Action {
            icon.name: "dialog-ok-apply"
            text: i18n("Accept")
            onTriggered: {
                currentWebView.grantFeaturePermission(
                    permissionQuestion.origin,
                    permissionQuestion.permission, true)
                permissionQuestion.visible = false
            }
        },
        Kirigami.Action {
            icon.name: "dialog-cancel"
            text: i18n("Decline")
            onTriggered: {
                currentWebView.grantFeaturePermission(
                    permissionQuestion.origin,
                    permissionQuestion.permission, false)
                downloadQuestion.visible = false
            }
        }
    ]
}
