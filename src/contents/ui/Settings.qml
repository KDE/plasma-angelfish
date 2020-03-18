/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Rinigus <rinigus.git@gmail.com>                        *
 *             2020 Jonah Brüchert  <jbb@kaidan.im>                        *
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
import Qt.labs.settings 1.0 as QtSettings

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mobile.angelfish 1.0

QtObject {
    id: settings

    // WebView
    property bool webAutoLoadImages: true
    property bool webJavascriptEnabled: true

    // Navigation bar
    property bool navBarMainMenu: true
    property bool navBarTabs: true
    property bool navBarBack: !Kirigami.Settings.isMobile
    property bool navBarForward: !Kirigami.Settings.isMobile
    property bool navBarReload: !Kirigami.Settings.isMobile
    property bool navBarContextMenu: true

    // Search engine
    property string searchCustomUrl

    ///////////////////////////////////
    // settings storage

    property QtSettings.Settings _settingsWebView: QtSettings.Settings {
        category: "WebView"
        property alias autoLoadImages: settings.webAutoLoadImages
        property alias javascriptEnabled: settings.webJavascriptEnabled
    }

    property QtSettings.Settings _settingsNavBar: QtSettings.Settings {
        category: "NavigationBar"
        property alias mainMenu: settings.navBarMainMenu
        property alias tabs: settings.navBarTabs
        property alias back: settings.navBarBack
        property alias forward: settings.navBarForward
        property alias reload: settings.navBarReload
        property alias contextMenu: settings.navBarContextMenu
    }

    property QtSettings.Settings _settingsSearch: QtSettings.Settings {
        category: "SearchEngine"
        property alias customUrl: settings.searchCustomUrl
    }
}
