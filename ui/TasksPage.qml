/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * SuperTask Pro - A task management system for Ubuntu Touch               *
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

    title: tasksList.title

    property TaskList tasksList

    property string noneMessage: i18n.tr("No tasks!")
    property var model: showCompletedTasks
                        ? tasksList.model
                        : tasksList.filteredTasks(function(task) { return !task.completed })

    actions: [
        Action {
            id: addAction

            iconSource: icon("add")
            text: i18n.tr("Add")

            onTriggered: {
                PopupUtils.open(addTaskSheet, root)
            }
        }

    ]

    ListView {
        id: tasksListView
        objectName: "tasksListView"

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: addBar.top
        }

        clip: true

        model: root.model

        delegate: TaskListItem {
            objectName: "task" + index

            task: modelData
            //text: title
        }

//        header: Subtitled {
//            text: "Blah"
//            subText: "Due Today"
//        }

//        footer: Standard {
//            text: "Control"
//            control: CheckBox {

//            }
//        }
    }

    Rectangle {
        id: addBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: addField.height + addBarDivider.height + units.gu(2)

        ThinDivider {
            id: addBarDivider

            anchors {
                left: parent.left
                right: parent.right
                bottom: addField.top
                bottomMargin: units.gu(1)
            }
        }

        TextField {
            id: addField
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(1)
            }

            placeholderText: i18n.tr("Add New Task")

            onAccepted: {
                tasksList.newTaskObject({
                                  title: addField.text
                              })
                addField.text = ""
            }
        }
    }

    Label {
        id: noTasksLabel
        objectName: "noTasksLabel"

        anchors.centerIn: parent

        visible: tasksList.length(root.model) === 0
        fontSize: "large"

        text: root.noneMessage
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: addAction
        }

        ToolbarButton {
            text: i18n.tr("Options")
            iconSource: icon("settings")

            onTriggered: {
                PopupUtils.open(optionsPopover, caller)
            }
        }
    }

    /* DIALOGS AND POPOVERS */

    Component {
        id: optionsPopover

        OptionsPopover {

        }
    }

    Component {
        id: addTaskSheet

        AddTaskSheet {

        }
    }

    Component {
        id: taskViewPage

        TaskViewPage {

        }
    }

    Component {
        id: taskActionsPopover

        ActionSelectionPopover {
            property var task

            actions: ActionList {
                Action {
                    id: deleteAction

                    text: i18n.tr("Delete")
                    onTriggered: task.remove()
                }
            }
        }
    }
}
