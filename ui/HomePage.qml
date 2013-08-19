/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <spencers1993@gmail.com>             *
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

Page {
    id: root

    title: wideAspect ? i18n.tr("Tasks")
                      : upcoming ? i18n.tr("Upcoming") : currentProject.name

    property var currentProject: null

    property var type: upcoming ? "upcoming" : "project"

    property bool upcoming: currentProject === null

    Sidebar {
        id: sidebar
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        Flickable {
            id: flickable
            anchors.fill: parent

            contentHeight: column.height
            contentWidth: width
            clip: true

            Column {
                id: column
                width: parent.width

                ProjectListItem {
                    project: null
                }

                Repeater {
                    model: backendModels

                    delegate: Column {
                        width: parent.width
                        Header {
                            text: modelData.name
                        }

                        Repeater {
                            model: modelData.projects

                            delegate: ProjectListItem {
                                project: modelData
                            }
                        }
                    }
                }
            }
        }

        Scrollbar {
            flickableItem: flickable
        }

        //width: units.gu(40)
        expanded: wideAspect
    }


    Item {
        anchors {
            top: parent.top
            bottom: addBar.top//parent.bottom
            right: parent.right
            left: sidebar.right
        }

        UpcomingTasksList {
            id: upcomingTasksList

            anchors.fill: parent
            visible: upcoming
        }

        TasksList {
            id: list

            showAddBar: false
            anchors.fill: parent
            project: currentProject
            visible: !upcoming
        }
    }

    QuickAddBar {
        id: addBar
        expanded: !upcoming
        anchors.left: sidebar.right
    }

    tools: ToolbarItems {

        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("Add")

            visible: currentProject != null

            onTriggered: {
                pageStack.push(addTaskPage, { project: currentProject })
            }
        }

        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("New")
            visible: sidebar.expanded

            onTriggered: {
                PopupUtils.open(newProjectDialog, caller)
            }
        }

        ToolbarButton {
            iconSource: icon("edit")
            text: i18n.tr("Rename")
            visible: currentProject != null

            onTriggered: {
                PopupUtils.open(renameProjectDialog, caller, {
                                    project: currentProject
                                })
            }
        }

        ToolbarButton {
            iconSource: icon("delete")
            text: i18n.tr("Delete")
            visible: currentProject != null

            onTriggered: {
                PopupUtils.open(confirmDeleteProjectDialog, caller, {
                                    project: currentProject
                                })
            }
        }

        ToolbarButton {
            text: i18n.tr("Options")
            iconSource: icon("settings")
            visible: sidebar.expanded

            onTriggered: {
                PopupUtils.open(optionsPopover, caller)
            }
        }
    }
}
