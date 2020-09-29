
/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Jonah Brüchert  <jbb@kaidan.im>                        *
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


import QtQuick 2.0
import org.kde.kirigami 2.4 as Kirigami


Kirigami.InlineMessage {
    id: newTabQuestion
    type: Kirigami.MessageType.Warning
    text: url ? i18n("Site wants to open a new tab: \n%1", url.toString()) : ""
    showCloseButton: true

    property url url

    actions: [
        Kirigami.Action {
            icon.name: "tab-new"
            text: i18n("Open")
            onTriggered: {
                tabs.tabsModel.newTab(newTabQuestion.url.toString())
                newTabQuestion.visible = false
            }
        }

    ]
}
