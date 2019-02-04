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
import QtQuick.Controls 2.0

import QtWebEngine 1.4


WebEngineView {
    id: webEngineView

    property string errorCode: ""
    property string errorString: ""
    property string userAgent: "Mozilla/5.0 (Linux; Plasma Mobile, like Android 7.0 ) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/60.0.3112.107 Mobile Safari/537.36"

    width: pageWidth
    height: pageHeight

    profile.httpUserAgent: userAgent

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
        if (loadRequest.status == WebEngineView.LoadStartedStatus) {
            if (contentView.state != "settings") { // Kludge!

                contentView.state = "hidden";
            }
        }
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
            contentView.state = "hidden"
        }
        errorCode = ec;
        errorString = es;
    }

//             onLoadProgressChanged: {
//                 if (loadProgress > 50) {
//                     contentView.state = "hidden";
//                 }
//             }

    Component.onCompleted: {
        print("WebView completed.");
        var settings = webEngineView.settings;
        print("Settings: " + settings);
    }

    onIconChanged: {
        if (icon)
            browserManager.history.updateIcon(url, icon)
    }
}
