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

    title: currentProject.supportsLists ? currentList.name : currentProject.name

    property var currentList
    property var currentProject: currentList.project

    property string type: "project"

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
            var list = subList(currentProject.lists, "name")
            list.push(i18n.tr("<i>New List...</i>"))
            return list
        }
        visible: currentProject.supportsLists

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

        list: currentList
    }

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: root.tools
                locked: true
                opened: true
            }
        }
    ]

    tools: ToolbarItems {
        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("New Task")
            enabled: currentList.editable

            onTriggered: {
                pageStack.push(Qt.resolvedUrl("AddTaskPage.qml"), {list: currentList})
            }
        }

        ToolbarButton {
            iconSource: icon("edit")
            text: i18n.tr("Rename")
            enabled: currentProject.editable

            onTriggered: {
                PopupUtils.open(renameProjectDialog, root, {
                                    project: currentProject
                                })
            }
        }

        ToolbarButton {
            iconSource: icon("save")
            text: i18n.tr("Archive")
            enabled: currentProject.editable
            visible: !currentProject.archived

            onTriggered: {
                while (pageStack.depth > 1)
                    pageStack.pop()
                currentProject.archived = true
            }
        }

        ToolbarButton {
            text: i18n.tr("Statistics")
            iconSource: icon("graphs")
            visible: currentProject.backend.supportsStatistics

            onTriggered: {
                showStatistics(currentProject)
            }
        }

        ToolbarButton {
            id: optionsButton
            text: i18n.tr("Options")
            iconSource: icon("settings")

            onTriggered: {
                PopupUtils.open(optionsPopover, optionsButton)
            }
        }
    }
}
