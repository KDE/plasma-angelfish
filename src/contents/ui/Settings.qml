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

import org.kde.kirigami 2.2 as Kirigami


ColumnLayout {
    id: settingsPage

    Controls.CheckDelegate {
        text: "Enable javascript"
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

    Controls.CheckDelegate {
        text: "Load images"
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

    Item {
        Layout.fillHeight: true
    }
}
