/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *
 *                                                                         *
 * This program is free software: you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program. If not, see <http://www.gnu.org/licenses/>.    *
 ***************************************************************************/
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "../components"
import "../backend/trello" as Trello

Page {
    id: root

    title: i18n.tr("Settings")

    property string type: "settings"

    Flickable {
        id: flickable
        anchors.fill: parent

        // FIXME: REALLY uggly hack (no idea why)
        anchors.topMargin: -1
        topMargin: 1

        contentHeight: column.height
        contentWidth: width
        //clip: true

        Column {
            id: column
            width: parent.width

//            Header {
//                text: i18n.tr("Plugins")
//            }

            Standard {
                text: i18n.tr("Connect to Trello")

                control: Switch {
                    checked: trelloIntegration
                    onCheckedChanged: {
                        saveSetting("trelloIntegration", checked ? "true" : "false")
                        checked = Qt.binding(function() { return trelloIntegration })
                        if (trelloIntegration) {
                            if (getSetting("trelloToken", "") === "") {
                                PopupUtils.open(trelloAuthentication, root)
                            } else {
                                goToProjects()
                                trello.load()
                            }
                        }
                    }
                }
            }

//            Header {
//                text: i18n.tr("Help & About")
//            }

            Standard {
                text: i18n.tr("About Ubuntu Tasks")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }

    Scrollbar {
        flickableItem: flickable
    }

    Component {
        id: trelloAuthentication

        Trello.TrelloAuthenticationDialog {
            onAccepted: {
                goToProjects()
                trello.connect()
            }
            onRejected: trelloIntegration = false
        }
    }
}
