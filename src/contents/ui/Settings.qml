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
import QtQuick.Layouts 1.11

import org.kde.kirigami 2.7 as Kirigami


Kirigami.ScrollablePage {
    title: i18n("Settings")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    Kirigami.ColumnView.fillWidth: false

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
    }

    ColumnLayout {
        id: settingsPage

        spacing: 0

        Kirigami.AbstractListItem {
            width: parent.width
            Controls.CheckBox {
                text: i18n("Enable JavaScript")
                Layout.fillWidth: true
                onCheckedChanged: {
                    var settings = currentWebView.settings;
                    settings.javascriptEnabled = checked;
                    // FIXME: save to config
                }
                Component.onCompleted: {
                    checked = currentWebView.settings.javascriptEnabled;
                }
            }
        }

        Kirigami.AbstractListItem {
            width: parent.width
            Controls.CheckBox {
                text: i18n("Load images")
                Layout.fillWidth: true
                onCheckedChanged: {
                    var settings = currentWebView.settings;
                    settings.autoLoadImages = checked;
                    // FIXME: save to config
                }
                Component.onCompleted: {
                    checked = currentWebView.settings.autoLoadImages;
                }
            }
        }

        InputSheet {
            id: homePagePopup
            title: i18n("Homepage")
            description: i18n("Website that should be loaded on startup")
            placeholderText: browserManager.homepage
            onAccepted: {
                if (homePagePopup.text !== "")
                    browserManager.homepage = browserManager.urlFromUserInput(homePagePopup.text)
            }
        }

        InputSheet {
            id: searchEnginePopup
            title: i18n("Search Engine")
            description: i18n("Base URL of your preferred search engine")
            placeholderText: browserManager.searchBaseUrl
            onAccepted: {
                if (searchEnginePopup.text !== "")
                    browserManager.searchBaseUrl = browserManager.urlFromUserInput(searchEnginePopup.text);
            }
        }

        Kirigami.BasicListItem {
            text: i18n("Homepage")
            Layout.fillWidth: true
            onClicked: {
                homePagePopup.open()
            }
        }

        Kirigami.BasicListItem {
            text: i18n("Search Engine")
            Layout.fillWidth: true
            onClicked: {
                searchEnginePopup.open()
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

