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
    title: i18n("Search Engine")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    Kirigami.ColumnView.fillWidth: false

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
    }

    property string baseUrl: Settings.searchBaseUrl

    ColumnLayout {
        id: list
        spacing: 0

        property string customName: i18n("Custom")

        // custom search engine input sheet
        InputSheet {
            id: searchEnginePopup
            title: i18n("Search Engine")
            description: i18n("Base URL of your preferred search engine")
            text: Settings.searchCustomUrl
            onAccepted: {
                const url = UrlUtils.urlFromUserInput(searchEnginePopup.text);
                Settings.searchCustomUrl = url;
                baseUrl = url;
                searchEngines.setProperty(searchEngines.count - 1, "url", url);
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Repeater {
            model: ListModel {
                id: searchEngines

                ListElement {
                    title: "Bing"
                    url: "https://www.bing.com/search?q="
                }

                ListElement {
                    title: "DuckDuckGo"
                    url: "https://start.duckduckgo.com/?q="
                }

                ListElement {
                    title: "Ecosia"
                    url: "https://www.ecosia.org/search?q="
                }

                ListElement {
                    title: "Google"
                    url: "https://www.google.com/search?q="
                }

                ListElement {
                    title: "Lilo"
                    url: "https://search.lilo.org/searchweb.php?q="
                }

                ListElement {
                    title: "Peekier"
                    url: "https://peekier.com/#!"
                }

                ListElement {
                    title: "Qwant"
                    url: "https://www.qwant.com/?q="
                }

                ListElement {
                    title: "Qwant Junior"
                    url: "https://www.qwantjunior.com/?q="
                }

                ListElement {
                    title: "StartPage"
                    url: "https://www.startpage.com/do/dsearch?query="
                }

                ListElement {
                    title: "Swisscows"
                    url: "https://swisscows.com/web?query="
                }

                ListElement {
                    title: "Wikipedia"
                    url: "https://wikipedia.org/wiki/Special:Search?search="
                }
            }

            delegate: ColumnLayout {
                spacing: 0

                Controls.RadioDelegate {
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit
                    implicitHeight: Kirigami.Units.gridUnit * 2.5
                    Layout.fillWidth: true
                    checked: model.url === baseUrl
                    text: model.title
                    onClicked: {
                        if (model.title !== list.customName)
                            baseUrl = model.url;
                        else {
                            searchEnginePopup.open();
                        }
                        // restore property binding
                        checked = Qt.binding(function() { return (model.url === baseUrl) });
                    }
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }
            }
        }
    }

    onBaseUrlChanged: {
        Settings.searchBaseUrl = UrlUtils.urlFromUserInput(baseUrl);
    }

    Component.onCompleted: {
        searchEngines.append({ "title": list.customName, "url": Settings.searchCustomUrl });
    }
}
