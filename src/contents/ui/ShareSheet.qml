/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>     *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

import QtQuick.Controls 2.1 as Controls
import QtQuick.Layouts 1.7
import QtQuick 2.7

import org.kde.kirigami 2.5 as Kirigami
import org.kde.purpose 1.0 as Purpose

Kirigami.OverlaySheet {
    id: inputSheet
    property url url
    property string title

    header: Kirigami.Heading {
        text: i18n("Share page")
    }

    Purpose.AlternativesView {
        id: view
        pluginType: "ShareUrl"
        implicitHeight: initialItem.contentHeight
        clip: true

        delegate: Kirigami.BasicListItem {
            label: model.display
            icon: "arrow-right"
            onClicked: view.createJob (model.index)
            Keys.onReturnPressed: view.createJob (model.index)
            Keys.onEnterPressed: view.createJob (model.index)
        }

        onFinished: close()
    }

    onSheetOpenChanged: {
        view.inputData = {
            "urls": [inputSheet.url.toString()],
            "title": inputSheet.title
        }
    }
}

