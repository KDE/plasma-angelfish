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

import QtWebEngine 1.7


WebEngineView {
    id: webEngineView

    property string errorCode: ""
    property string errorString: ""
    property string userAgent: "Mozilla/5.0 (Linux; Plasma Mobile, like Android 9.0 ) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/69.0.3497.128 Mobile Safari/537.36"

    width: pageWidth
    height: pageHeight

    profile {
        httpUserAgent: userAgent
        onDownloadRequested: {
            showPassiveNotification(i18n("Do you want to download this file?"), "long", "Download", function() {
                download.accept
            })
        }
        onDownloadFinished: showPassiveNotification(i18n("Download finished"))
    }
    settings {
        errorPageEnabled: false
    }

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
            onTriggered:  webEngineView.triggerWebAction(WebEngineView.CopyLinkToClipboard)
        }
        Controls.MenuItem {
            text: i18n("View source")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.ViewSource)
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

    //Rectangle { color: "yellow"; opacity: 0.3; anchors.fill: parent }
    focus: true
    onLoadingChanged: { // Doesn't work!?!
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
        //print("Load: " + loadRequest.errorCode + " " + loadRequest.errorString);
        //if (loadRequest.status == WebEngineView.LoadStartedStatus) {
        //}
        if (loadRequest.status == WebEngineView.LoadSucceededStatus) {
            // record history, set current page info
            //contentView.state = "hidden"
            //pageInfo.url = webEngineView.url;
            //pageInfo.title = webEngineView.title;
            //pageInfo.icon = webEngineView.icon;
            addHistoryEntry();

        }
        if (loadRequest.status == WebEngineView.LoadFailedStatus) {
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
        newTab(request.requestedUrl.toString())
        showPassiveNotification("Website was opened in a new tab")
    }

    onContextMenuRequested: {
        request.accepted = true;
        contextMenu.request = request
        contextMenu.x = request.x
        contextMenu.y = request.y
        contextMenu.open()
    }
}
