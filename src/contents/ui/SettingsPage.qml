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
import org.kde.mobile.angelfish 1.0

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

        Controls.SwitchDelegate {
            text: i18n("Enable JavaScript")
            Layout.fillWidth: true
            checked: settings.webJavascriptEnabled
            onCheckedChanged: settings.webJavascriptEnabled = checked
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: Kirigami.Units.gridUnit * 2.5
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Load images")
            Layout.fillWidth: true
            checked: settings.webAutoLoadImages
            onCheckedChanged: settings.webAutoLoadImages = checked
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: Kirigami.Units.gridUnit * 2.5
        }

//        InputSheet {
//            id: homePagePopup
//            title: i18n("Homepage")
//            description: i18n("Website that should be loaded on startup")
//            placeholderText: BrowserManager.homepage
//            onAccepted: {
//                if (homePagePopup.text !== "")
//                    BrowserManager.homepage = UrlUtils.urlFromUserInput(homePagePopup.text)
//            }
//        }

//        Kirigami.Separator {
//            Layout.fillWidth: true
//        }

//        Controls.ItemDelegate {
//            text: i18n("Homepage")
//            Layout.fillWidth: true
//            onClicked: {
//                homePagePopup.open()
//            }
//            leftPadding: Kirigami.Units.gridUnit
//            rightPadding: Kirigami.Units.gridUnit
//            implicitHeight: Kirigami.Units.gridUnit * 2.5
//        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.ItemDelegate {
            text: i18n("Search Engine")
            Layout.fillWidth: true
            onClicked: pageStack.push(Qt.resolvedUrl("SettingsSearchEnginePage.qml"))
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: Kirigami.Units.gridUnit * 2.5
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.ItemDelegate {
            text: i18n("Navigation bar")
            Layout.fillWidth: true
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: Kirigami.Units.gridUnit * 2.5
            onClicked: pageStack.push(Qt.resolvedUrl("SettingsNavigationBarPage.qml"))
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
