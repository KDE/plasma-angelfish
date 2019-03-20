/***************************************************************************
 *                                                                         *
 *   Copyright 2019 Simon Schmeisser <s.schmeisser@gmx.net>                *
 *   Copyright 2019 Jonah Brüchert <jbb@kaidan.im>                         *
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

import QtQuick 2.7
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.5 as Kirigami

ListView {
    id: completion

    property string searchText

    Behavior on height {
        SmoothedAnimation {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        z: -1
        anchors.fill: parent
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
    }

    layer.enabled: completion.visible
    layer.effect: DropShadow {
        verticalOffset: - 1
        color: Kirigami.Theme.disabledTextColor
        samples: 10
        spread: 0.1
        cached: true // element is static
    }

    verticalLayoutDirection: ListView.BottomToTop
    clip: true

    delegate: UrlDelegate {
        showRemove: false
        onClicked: tabs.forceActiveFocus()
        highlightText: completion.searchText
    }

    states: [
        State {
            name: "hidden"
            when: visible === false
            PropertyChanges {
                target: completion
                height: 0
            }
        }
    ]
}
