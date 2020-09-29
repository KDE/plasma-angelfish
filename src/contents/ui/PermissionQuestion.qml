/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import org.kde.kirigami 2.4 as Kirigami
import QtWebEngine 1.9

Kirigami.InlineMessage {
    property int permission
    property string origin

    id: permissionQuestion
    text: {
        switch(permission) {
        case WebEngineView.Geolocation:
            i18n("Do you want to allow the website to access the geo location?")
            break
        case WebEngineView.MediaAudioCapture:
            i18n("Do you want to allow the website to access the microphone?")
            break
        case WebEngineView.MediaVideoCapture:
            i18n("Do you want to allow the website to access the camera?")
            break
        case WebEngineView.MediaAudioVideoCapture:
            i18n("Do you want to allow the website to access the camera and the microphone?")
            break
        case WebEngineView.DesktopVideoCapture:
            i18n("Do you want to allow the website to share your screen?")
            break
        case WebEngineView.DesktopAudioVideoCapture:
            i18n("Do you want to allow the website to share the sound output?")
            break
        case WebEngineView.Notifications:
            i18n("Do you want to allow the website to send you notifications?")
            break
        }
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
                permissionQuestion.visible = false
            }
        }
    ]
}
