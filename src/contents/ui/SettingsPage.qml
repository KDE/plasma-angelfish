/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>    *
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
            checked: Settings.webJavaScriptEnabled
            onClicked: Settings.webJavaScriptEnabled = checked
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
            checked: Settings.webAutoLoadImages
            onClicked: Settings.webAutoLoadImages = checked
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: Kirigami.Units.gridUnit * 2.5
        }

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

        Controls.ItemDelegate {
            text: i18n("Adblock filter lists")
            Layout.fillWidth: true
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            implicitHeight: Kirigami.Units.gridUnit * 2.5
            onClicked: pageStack.push(Qt.resolvedUrl("SettingsAdblock.qml"))
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
