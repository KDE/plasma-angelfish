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
