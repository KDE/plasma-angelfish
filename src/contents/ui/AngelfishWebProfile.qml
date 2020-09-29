/***************************************************************************
 *                                                                         *
 *   Copyright 2017-2020 Jonah Brüchert <jbb@kadan.im>                     *
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

    onDownloadFinished: (download) => {
        switch (download.state) {
        case WebEngineDownloadItem.DownloadCompleted:
            showPassiveNotification(i18n("Download finished"))
            break;
        case WebEngineDownloadItem.DownloadInterrupted:
            showPassiveNotification(i18n("Download failed"))
            console.log("Download interrupt reason: " + download.interruptReason)
            break;
        case WebEngineDownloadItem.DownloadCancelled:
            console.log("Download cancelled by the user")
            break;
        }
    }
}
