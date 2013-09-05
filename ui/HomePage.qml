/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *                                                                         *
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
import "../ubuntu-ui-extras"

Page {
    id: root

    title: wideAspect ? i18n.tr("Tasks")
                      : projectName

    property string projectName: upcoming ? i18n.tr("Upcoming") : currentProject.name

    property var type: upcoming ? "upcoming" : "project"

    property bool upcoming: currentProject === null

    property var currentProject: null

    onCurrentProjectChanged: {
        currentList = null

        if (currentProject !== null) {
            if (currentProject.lists.count > 0) {
                currentList = currentProject.lists.get(0).modelData

                for (var i = 0; i < length(currentProject.lists); i++) {
                    if (get(currentProject.lists, i).name === "To Do") {
                        currentList = get(currentProject.lists, i)
                        break
                    }
                }
            }
        }
    }

    property var currentList: null

    onCurrentListChanged: {
        if (currentList !== null && currentList.tasks.count > 0)
            currentTask = currentList.tasks.get(0).modelData
    }

    property var currentTask: null

    property bool showArchived: false

    property bool supportsLists: currentProject !== null && currentProject.supportsLists

    Sidebar {
        id: sidebar

        Column {
            id: column
            width: parent.width

            ProjectListItem {
                project: null
            }

            Repeater {
                model: localProjectsModel.projects

                delegate: ProjectListItem {
                    project: modelData
                    visible: modelData.special
                }
            }

            Repeater {
                model: backendModels

                delegate: Column {
                    width: parent.width
                    visible: modelData.enabled
                    Header {
                        text: modelData.name

                        ActivityIndicator {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: units.gu(2)
                            }

                            visible: running
                            running: modelData.loading > 0
                        }
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

        Item {
            anchors.fill: parent

            visible: !upcoming

            ValueSelector {
                id: listSelector
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0.2,0.2,0.2,0.2)
                }

                text: i18n.tr("List")
                values: {
                    var list = subList(currentProject === null ? [] : currentProject.lists, "name")
                    list.push(i18n.tr("<i>New List...</i>"))
                    return list
                }
                visible: currentProject && currentProject.supportsLists

                onSelectedIndexChanged: {
                    if (selectedIndex === values.length - 1) {
                        print("NEW LIST...")
                    } else {
                        currentList = currentProject.lists.get(selectedIndex).modelData
                    }
                }
            }

            TasksList {
                id: list

                anchors {
                    left: parent.left
                    right: parent.right
                    top: listSelector.visible ? listSelector.bottom : parent.top
                    bottom: parent.bottom
                }

                showAddBar: false
                list: currentList
            }
        }
    }

    QuickAddBar {
        id: addBar
        expanded: currentProject !== null && currentProject.editable
        anchors.left: sidebar.right
    }

    onActiveChanged: tools.opened = wideAspect

    tools: ToolbarItems {
        locked: wideAspect
        opened: wideAspect

        ToolbarButton {
            id: newProjectButton
            iconSource: icon("add")
            text: i18n.tr("New Project")
            visible:  sidebar.expanded || currentProject === null

            onTriggered: {
                newProject(newProjectButton)
            }
        }

        Item {
            height: parent.height
            width: units.gu(0.5)
        }

        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("Add Task")
            visible: currentProject !== null
            enabled: currentProject !== null && currentProject.editable

            onTriggered: {
                pageStack.push(Qt.resolvedUrl("AddTaskPage.qml"), {list: currentList})
            }
        }

        ToolbarButton {
            iconSource: icon("edit")
            text: i18n.tr("Rename")
            visible: currentProject !== null
            enabled: currentProject !== null && currentProject.editable

            onTriggered: {
                PopupUtils.open(renameProjectDialog, root, {
                                    project: currentProject
                                })
            }
        }

        ToolbarButton {
            iconSource: icon("save")
            text: i18n.tr("Archive")
            enabled: currentProject !== null && currentProject.editable
            visible: currentProject !== null && !currentProject.archived

            onTriggered: {
                currentProject.archived = true
                currentProject = null
            }
        }

        ToolbarButton {
            text: i18n.tr("Statistics")
            iconSource: icon("graphs")
            visible: currentProject != null && currentProject.backend.supportsStatistics

            onTriggered: {
                showStatistics(currentProject)
            }
        }

        ToolbarButton {
            id: optionsButton
            text: i18n.tr("Options")
            iconSource: icon("settings")
            visible: wideAspect || currentProject !== null

            onTriggered: {
                PopupUtils.open(optionsPopover, optionsButton)
            }
        }
    }
}
