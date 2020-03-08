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
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.11

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mobile.angelfish 1.0

Kirigami.ScrollablePage {
    title: i18n("Navigation bar")

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
        spacing: 0

        property real itemHeight: Kirigami.Units.gridUnit * 2.5

        Controls.Label {
            text: i18n("Choose the buttons enabled in navigation bar. " +
                       "Some of the buttons can be hidden only in portrait " +
                       "orientation of the browser and are always shown if " +
                       "the browser is wider than its height.\n\n" +
                       "Note that if you disable the menu buttons, you " +
                       "will be able to access the menus either by swiping " +
                       "from the left or right side or to a side along the bottom " +
                       "of the window.")
            Layout.fillWidth: true
            padding: Kirigami.Units.gridUnit
            wrapMode: Text.WordWrap
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Main menu in portrait")
            Layout.fillWidth: true
            checked: settings.navBarMainMenu
            horizontalPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: settings.navBarMainMenu = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Tabs in portrait")
            Layout.fillWidth: true
            checked: settings.navBarTabs
            horizontalPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: settings.navBarTabs = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Context menu in portrait")
            Layout.fillWidth: true
            checked: settings.navBarContextMenu
            horizontalPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: settings.navBarContextMenu = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Go back")
            Layout.fillWidth: true
            checked: settings.navBarBack
            horizontalPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: settings.navBarBack = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Go forward")
            Layout.fillWidth: true
            checked: settings.navBarForward
            horizontalPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: settings.navBarForward = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Reload/Stop")
            Layout.fillWidth: true
            checked: settings.navBarReload
            horizontalPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: settings.navBarReload = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
