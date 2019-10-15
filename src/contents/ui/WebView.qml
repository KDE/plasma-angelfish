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

WebEngineView {
    id: webEngineView

    property string errorCode: ""
    property string errorString: ""

    /**
      * User agent used on mobile devices
      */
    property string mobileUserAgent: "Mozilla/5.0 (Linux; Plasma Mobile, like Android 9.0 ) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/69.0.3497.128 Mobile Safari/537.36"

    /**
      * User agent used on desktop devices,
      * Defaults to QtWebEngine's default (it is only supported on desktop devices by Qt currently)
      */
    property string desktopUserAgent: profile.httpUserAgent

    width: pageWidth
    height: pageHeight

    profile {
        httpUserAgent: {
            if (Kirigami.Settings.isMobile)
                return mobileUserAgent
            else
                return desktopUserAgent
        }

        offTheRecord: rootPage.privateMode

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

    settings {
        // Disable builtin error pages in favor of our own
        errorPageEnabled: false
    }

    // Custom context menu
    Controls.Menu {
        property var request
        id: contextMenu

        Controls.MenuItem {
            text: i18n("Copy")
            enabled: (contextMenu.request.editFlags & ContextMenuRequest.CanCopy) != 0
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Copy)
        }
        Controls.MenuItem {
            text: i18n("Cut")
            enabled: (contextMenu.request.editFlags & ContextMenuRequest.CanCut) != 0
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Cut)
        }
        Controls.MenuItem {
            text: i18n("Paste")
            enabled: (contextMenu.request.editFlags & ContextMenuRequest.CanPaste) != 0
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Paste)
        }
        Controls.MenuItem {
            enabled: contextMenu.request.linkUrl !== ""
            text: i18n("Copy Url")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyLinkToClipboard)
        }
        Controls.MenuItem {
            text: i18n("View source")
            onTriggered: newTab("view-source:" + webEngineView.url)
        }
        Controls.MenuItem {
            text: i18n("Download")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.DownloadLinkToDisk)
        }
        Controls.MenuItem {
            enabled: contextMenu.request.linkUrl !== ""
            text: i18n("Open in new Tab")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.OpenLinkInNewTab)
        }
    }

    focus: true
    onLoadingChanged: {
        //print("Loading: " + loading);
        print("    url: " + loadRequest.url)
        //print("   icon: " + webEngineView.icon)
        //print("  title: " + webEngineView.title)

        /* Handle
        *  - WebEngineView::LoadStartedStatus,
        *  - WebEngineView::LoadStoppedStatus,
        *  - WebEngineView::LoadSucceededStatus and
        *  - WebEngineView::LoadFailedStatus
        */
        var ec = "";
        var es = "";
        if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
            if (!rootPage.privateMode) {
                addHistoryEntry();
            }
        }
        if (loadRequest.status === WebEngineView.LoadFailedStatus) {
            print("Load failed: " + loadRequest.errorCode + " " + loadRequest.errorString);
            ec = loadRequest.errorCode;
            es = loadRequest.errorString;
        }
        errorCode = ec;
        errorString = es;
    }

    Component.onCompleted: {
        print("WebView completed.");
        var settings = webEngineView.settings;
        print("Settings: " + settings);
    }

    onIconChanged: {
        if (icon)
            browserManager.history.updateIcon(url, icon)
    }

    onNewViewRequested: {
        if (request.userInitiated) {
            newTab(request.requestedUrl.toString())
            showPassiveNotification(i18n("Website was opened in a new tab"))
        } else {
            questionLoader.setSource("NewTabQuestion.qml")
            questionLoader.item.url = request.requestedUrl
            questionLoader.item.visible = true
        }
    }

    onFullScreenRequested: {
        request.accept()
        if (webBrowser.visibility !== Window.FullScreen)
            webBrowser.showFullScreen()
        else
            webBrowser.showNormal()
    }

    onContextMenuRequested: {
        request.accepted = true // Make sure QtWebEngine doesn't show its own context menu.
        contextMenu.request = request
        contextMenu.x = request.x
        contextMenu.y = request.y
        contextMenu.open()
    }

    onAuthenticationDialogRequested: {
        request.accepted = true
        sheetLoader.setSource("AuthSheet.qml")
        sheetLoader.item.request = request
        sheetLoader.item.open()
    }

    onFeaturePermissionRequested: {
        questionLoader.setSource("PermissionQuestion.qml")
        questionLoader.item.permission = feature
        questionLoader.item.origin = securityOrigin
        questionLoader.item.visible = true
    }
}
