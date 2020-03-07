import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.2

import QtWebEngine 1.4

Kirigami.OverlaySheet {
    id: dialogSheet
    property JavaScriptDialogRequest request

    Item {
        Component {
            id: alert

            Controls.Button {
                text: i18n("Close")
                onClicked: {
                    dialogSheet.request.dialogReject()
                    dialogSheet.close()
                }
            }
        }

        Component {
            id: confirm

            Controls.Button {
                text: i18n("Confirm")
                onClicked: {
                    dialogSheet.request.dialogAccept()
                    dialogSheet.close()
                }
            }
        }

        Component {
            id: prompt

            ColumnLayout {
                Controls.TextField {
                    id: inputField
                    Layout.fillWidth: true
                    text: dialogSheet.request.defaultText
                }

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Button {
                        Layout.fillWidth: true
                        text: i18n("Cancel")
                        onClicked: {
                            dialogSheet.request.dialogReject()
                            dialogSheet.close()
                        }
                    }

                    Controls.Button {
                        Layout.fillWidth: true
                        text: i18n("Submit")
                        onClicked: {
                            dialogSheet.request.dialogAccept(inputField.text)
                            dialogSheet.close()
                        }
                    }
                }
            }
        }

        Component {
            id: beforeUnload

            Controls.Button {
                text: i18n("Leave page")
                onClicked: {
                    dialogSheet.request.dialogAccept()
                    dialogSheet.close()
                }
            }
        }
    }

    onSheetOpenChanged: {
        if (dialogSheet.sheetOpen) {
            switch(request.type) {
            case JavaScriptDialogRequest.DialogTypeAlert:
                controlLoader.sourceComponent = alert
                break
            case JavaScriptDialogRequest.DialogTypeConfirm:
                controlLoader.sourceComponent = confirm
                break
            case JavaScriptDialogRequest.DialogTypePrompt:
                controlLoader.sourceComponent = prompt
                break
            case JavaScriptDialogRequest.DialogTypeBeforeUnload:
                controlLoader.sourceComponent = beforeUnload
                break
            }
        } else {
            dialogSheet.request.dialogReject()
        }
    }

    ColumnLayout {
        Controls.Label {
            visible: text
            text: {
                if (request) {
                    if (request.message) {
                        return request.message
                    }

                    if (request.type == JavaScriptDialogRequest.DialogTypeBeforeUnload) {
                        return i18n("The website asks for confirmation that you want to leave. Unsaved information might not be saved.")
                    }
                }

                return ""
            }
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
        }
        Loader {
            Layout.fillWidth: true
            id: controlLoader
        }
    }
}
