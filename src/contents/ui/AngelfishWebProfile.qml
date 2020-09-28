import QtWebEngine 1.7
import QtQuick 2.7

WebEngineProfile {
    // TODO Qt 5.15 make required
    property Loader questionLoader

    onDownloadRequested: (download) => {
        // if we don't accept the request right away, it will be deleted
        download.accept()
        // therefore just stop the download again as quickly as possible,
        // and ask the user for confirmation
        download.pause()

        questionLoader.setSource("DownloadQuestion.qml")
        questionLoader.item.download = download
        questionLoader.item.visible = true
    }

    onDownloadFinished: {
        if (download.state === WebEngineDownloadItem.DownloadCompleted) {
            showPassiveNotification(i18n("Download finished"))
        }
        else if (download.state === WebEngineDownloadItem.DownloadInterrupted) {
            showPassiveNotification(i18n("Download failed"))
            console.log("Download interrupt reason: " + download.interruptReason)
        }
        else if (download.state === WebEngineDownloadItem.DownloadCancelled) {
            console.log("Download cancelled by the user")
        }
    }
}
