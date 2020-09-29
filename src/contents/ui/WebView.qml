/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 2.4 as Controls
import QtQuick.Window 2.1
import QtQuick.Layouts 1.3
import QtWebEngine 1.10

import org.kde.kirigami 2.4 as Kirigami
import org.kde.mobile.angelfish 1.0


WebEngineView {
    id: webEngineView

    property string errorCode: ""
    property string errorString: ""

    property bool privateMode: false

    property alias userAgent: userAgent

    // loadingActive property is set to true when loading is started
    // and turned to false only after succesful or failed loading. It
    // is possible to set it to false by calling stopLoading method.
    //
    // The property was introduced as it triggers visibility of the webEngineView
    // in the other parts of the code. When using loading that is linked
    // to visibility, stop/start loading was observed in some conditions. It looked as if
    // there is an internal optimization of webengine in the case of parallel
    // loading of several pages that could use visibility as one of the decision
    // making parameters.
    property bool loadingActive: false

    // reloadOnVisible property ensures that the view has been always
    // loaded at least once while it is visible. When the view is loaded
    // while visible is set to false, there, what appears to be Chromium
    // optimizations that can disturb the loading.
    property bool reloadOnVisible: true

    // Profiles of WebViews are shared among all views of the same type (regular or
    // private). However, within each group of tabs, we can have some tabs that are
    // using mobile or desktop user agent. To avoid loading a page with the wrong
    // user agent, the agent is checked in the beginning of the loading at onLoadingChanged
    // handler. If the user agent is wrong, loading is stopped and reloadOnMatchingAgents
    // property is set to true. As soon as the agent is correct, the page is loaded.
    property bool reloadOnMatchingAgents: false

    // Used to follow whether agents match
    property bool agentsMatch: profile.httpUserAgent === userAgent.userAgent

    // URL that was requested and should be used
    // as a base for user interaction. It reflects
    // last request (successful or failed)
    property url requestedUrl: url

    property int findInPageResultIndex
    property int findInPageResultCount

    // Menu that can be overriden from subclasses
    property Controls.Menu contextMenu: Controls.Menu {
        property ContextMenuRequest request

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
            onTriggered: tabsModel.newTab(UrlUtils.urlFromUserInput(Settings.searchBaseUrl + contextMenu.request.selectedText));
        }
        Controls.MenuItem {
            enabled: contextMenu.request && contextMenu.request.linkUrl !== ""
            text: i18n("Copy Url")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyLinkToClipboard)
        }
        Controls.MenuItem {
            text: i18n("View source")
            onTriggered: tabsModel.newTab("view-source:" + webEngineView.url)
        }
        Controls.MenuItem {
            text: i18n("Download")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.DownloadLinkToDisk)
        }
        Controls.MenuItem {
            enabled: contextMenu.request && contextMenu.request.linkUrl !== ""
            text: i18n("Open in new Tab")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.OpenLinkInNewTab)
        }
    }


    UserAgentGenerator {
        id: userAgent
        onUserAgentChanged: webEngineView.reload()
    }

    settings {
        autoLoadImages: Settings.webAutoLoadImages
        javascriptEnabled: Settings.webJavaScriptEnabled
        // Disable builtin error pages in favor of our own
        errorPageEnabled: false
        // Load larger touch icons
        touchIconsEnabled: true
        // Disable scrollbars on mobile
        showScrollBars: false
    }

    focus: true
    onLoadingChanged: {
        //print("Loading: " + loading);
        print("    url: " + loadRequest.url + " " + loadRequest.status)
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
        if (loadRequest.status === WebEngineView.LoadStartedStatus) {
            if (profile.httpUserAgent !== userAgent.userAgent) {
                //print("Mismatch of user agents, will load later " + loadRequest.url);
                reloadOnMatchingAgents = true;
                stopLoading();
            } else {
                loadingActive = true;
            }
        }
        if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
            if (!privateMode) {
                const request = {
                    url: currentWebView.url,
                    title: currentWebView.title,
                    icon: currentWebView.icon
                }

                BrowserManager.addToHistory(request);
                BrowserManager.updateLastVisited(currentWebView.url);
            }
            loadingActive = false;
        }
        if (loadRequest.status === WebEngineView.LoadFailedStatus) {
            print("Load failed: " + loadRequest.errorCode + " " + loadRequest.errorString);
            print("Load failed url: " + loadRequest.url + " " + url);
            ec = loadRequest.errorCode;
            es = loadRequest.errorString;
            loadingActive = false;

            // update requested URL only after its clear that it fails.
            // Otherwise, its updated as a part of url property update.
            if (requestedUrl !== loadRequest.url)
                requestedUrl = loadRequest.url;
        }
        errorCode = ec;
        errorString = es;
    }

    Component.onCompleted: {
        print("WebView completed.");
        print("Settings: " + webEngineView.settings);
    }

    onIconChanged: {
        if (icon && !privateMode)
            BrowserManager.updateIcon(url, icon)
    }

    onNewViewRequested: {
        if (request.userInitiated) {
            tabsModel.newTab(request.requestedUrl.toString())
            showPassiveNotification(i18n("Website was opened in a new tab"))
        } else {
            questionLoader.setSource("NewTabQuestion.qml")
            questionLoader.item.url = request.requestedUrl
            questionLoader.item.visible = true
        }
    }

    onUrlChanged: {
        if (requestedUrl !== url) {
            requestedUrl = url;
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

    onJavaScriptDialogRequested: {
        request.accepted = true
        sheetLoader.setSource("JavaScriptDialogSheet.qml")
        sheetLoader.item.request = request
        sheetLoader.item.open()
    }

    onFindTextFinished: {
        findInPageResultIndex = result.activeMatch;
        findInPageResultCount = result.numberOfMatches;
    }

    onVisibleChanged: {
        if (visible && reloadOnVisible) {
            // see description of reloadOnVisible above for reasoning
            reloadOnVisible = false;
            reload();
        }
    }

    onAgentsMatchChanged: {
        if (agentsMatch && reloadOnMatchingAgents) {
            // see description of reloadOnMatchingAgents above for reasoning
            reloadOnMatchingAgents = false;
            reload();
        }
    }

    function findInPageBack(text) {
        findText(text, WebEngineView.FindBackward);
    }

    function findInPageForward(text) {
        findText(text);
    }

    function stopLoading() {
        loadingActive = false;
        stop();
    }
}
