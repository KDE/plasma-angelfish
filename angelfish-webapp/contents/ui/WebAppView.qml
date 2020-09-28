/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
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

import QtQuick 2.3
import QtQuick.Controls 2.4 as Controls
import QtQuick.Window 2.1
import QtQuick.Layouts 1.3
import QtWebEngine 1.7

import org.kde.kirigami 2.4 as Kirigami
import org.kde.mobile.angelfish 1.0

WebView {
    id: webEngineView

    profile: WebEngineProfile {
        httpUserAgent: userAgent.userAgent

        onDownloadRequested: {
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

    // Custom context menu
    contextMenu: Controls.Menu {
        property ContextMenuRequest request
        id: contextMenu

        Controls.MenuItem {
            enabled: contextMenu.request && (contextMenu.request.editFlags & ContextMenuRequest.CanCopy) != 0
            text: i18n("Copy")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Copy)
        }
        Controls.MenuItem {
            enabled: contextMenu.request && (contextMenu.request.editFlags & ContextMenuRequest.CanCut) != 0
            text: i18n("Cut")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Cut)
        }
        Controls.MenuItem {
            enabled: contextMenu.request && (contextMenu.request.editFlags & ContextMenuRequest.CanPaste) != 0
            text: i18n("Paste")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Paste)
        }
        Controls.MenuItem {
            enabled: contextMenu.request && contextMenu.request.selectedText
            text: contextMenu.request && contextMenu.request.selectedText ? i18n("Search online for '%1'", contextMenu.request.selectedText) : i18n("Search online")
            onTriggered: Qt.openUrlExternally(UrlUtils.urlFromUserInput(Settings.searchBaseUrl + contextMenu.request.selectedText));
        }
        Controls.MenuItem {
            enabled: contextMenu.request && contextMenu.request.linkUrl !== ""
            text: i18n("Copy Url")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyLinkToClipboard)
        }
        Controls.MenuItem {
            text: i18n("Download")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.DownloadLinkToDisk)
        }
    }

    onNewViewRequested: {
        if (UrlUtils.urlHost(request.requestedUrl) === UrlUtils.urlHost( BrowserManager.initialUrl)) {
            url = request.requestedUrl;
        } else {
            Qt.openUrlExternally(request.requestedUrl);
        }
    }
}
