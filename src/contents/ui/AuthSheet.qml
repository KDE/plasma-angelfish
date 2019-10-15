import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

Kirigami.OverlaySheet {
    id: authSheet
    property var request

    Kirigami.FormLayout {
        Layout.fillWidth: true

        Kirigami.Heading {
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            Layout.fillWidth: true

            text: i18n("Authentication required")
        }

        Controls.TextField {
            id: usernameField

            Kirigami.FormData.label: i18n("Username")
            Layout.fillWidth: true
        }
        Controls.TextField {
            id: passwordField
            echoMode: TextInput.Password

            Kirigami.FormData.label: i18n("Password")
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            Controls.Button {
                Layout.fillWidth: true
                text: i18n("Accept")

                onClicked: {
                    authSheet.request.dialogAccept(usernameField.text, passwordField.text)
                    authSheet.close()
                }
            }
            Controls.Button {
                Layout.fillWidth: true
                text: i18n("Cancel")

                onClicked: {
                    authSheet.request.dialogReject()
                    authSheet.close()
                }
            }
        }
    }
}
