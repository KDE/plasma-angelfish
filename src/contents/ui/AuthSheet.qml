/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Jonah Brüchert  <jbb@kaidan.im>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/


import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

import QtWebEngine 1.4

Kirigami.OverlaySheet {
    id: authSheet
    property AuthenticationDialogRequest request

    header: Kirigami.Heading {
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        Layout.fillWidth: true

        text: i18n("Authentication required")
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true

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
