/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert  <jbb@kaidan.im>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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
            checked: Settings.navBarMainMenu
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: Settings.navBarMainMenu = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Tabs in portrait")
            Layout.fillWidth: true
            checked: Settings.navBarTabs
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: Settings.navBarTabs = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Context menu in portrait")
            Layout.fillWidth: true
            checked: Settings.navBarContextMenu
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: Settings.navBarContextMenu = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Go back")
            Layout.fillWidth: true
            checked: Settings.navBarBack
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: Settings.navBarBack = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Go forward")
            Layout.fillWidth: true
            checked: Settings.navBarForward
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: Settings.navBarForward = checked
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.SwitchDelegate {
            text: i18n("Reload/Stop")
            Layout.fillWidth: true
            checked: Settings.navBarReload
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: parent.itemHeight
            onCheckedChanged: Settings.navBarReload = checked
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
