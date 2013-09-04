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

Popover {
    id: optionsPopover

    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Standard {
            //FIXME: Hack because of Suru theme!
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                text: i18n.tr("Show Completed Tasks")
                fontSize: "medium"
                color: Theme.palette.normal.overlayText
            }

            //text: i18n.tr("Show Completed Tasks")

            control: CheckBox {
                checked: showCompletedTasks
                onCheckedChanged: saveSetting("showCompletedTasks", checked ? "true" : "false")
            }

            visible: currentProject !== null

            showDivider: showArchivedProjectsAction.visible || refreshTrelloAction.visible
        }

        Standard {
            id: showArchivedProjectsAction
            //FIXME: Hack because of Suru theme!
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                text: i18n.tr("Show Archived Projects")
                fontSize: "medium"
                color: Theme.palette.normal.overlayText
            }

            onClicked: {
                __makeInvisible()
                PopupUtils.close(optionsPopover)
                pageStack.push(Qt.resolvedUrl("../ui/ProjectsPage.qml"), {showArchived: true, objectName: "archivedProjectsPage"})
            }

            visible: wideAspect

            showDivider: refreshTrelloAction.visible
        }

        Standard {
            id: refreshTrelloAction
            //FIXME: Hack because of Suru theme!
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                text: i18n.tr("Refresh Trello boards")
                fontSize: "medium"
                color: Theme.palette.normal.overlayText
            }

            onClicked: {
                PopupUtils.close(optionsPopover)
                trello.load()
            }

            visible: (wideAspect || currentProject === null || currentProject.backend === trello) && trelloIntegration

            showDivider: false
        }
    }
}
