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
    id: root

    property var task
    property bool showArchived: false

    Column {
        id: projectsColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Repeater {
            id: modelRepeater
            model: [localProjectsModel]

            delegate: Column {
                width: parent.width
                visible: modelData.enabled && (modelData.openProjectsCount) > 0
                Header {
                    text: modelData.name
                }

                Repeater {
                    id: repeater
                    model: modelData.projects

                    delegate: Standard {
                        //FIXME: Hack because of Suru theme!
                        Label {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                margins: units.gu(2)
                            }

                            text: modelData.name
                            fontSize: "medium"
                            color: selected ? UbuntuColors.orange : Theme.palette.normal.overlayText
                        }

                        selected: task.project === modelData
                        enabled: task.canMoveToProject(modelData)
                        visible: !(modelData.special || modelData.archived)

                        onClicked: {
                            task.moveToProject(modelData)
                            PopupUtils.close(root)
                        }

                        showDivider: index < repeater.count - 1
                    }
                }
            }
        }

        Divider {}

        Standard {
            //FIXME: Hack because of Suru theme!
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                text: i18n.tr("<i>New Project...</i>")
                fontSize: "medium"
                color: Theme.palette.normal.overlayText
            }

            onClicked: {
                PopupUtils.close(root)
                //newProject(root.caller, task)
                PopupUtils.open(newProjectDialog, root.caller, {
                                    backend: localProjectsModel,
                                    task: task
                                })
            }

            showDivider: false
        }
    }
}
