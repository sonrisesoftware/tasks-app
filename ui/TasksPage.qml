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

    title: i18n.tr("Tasks")

    property string noneMessage: i18n.tr("No tasks!")
    property var model: tasksModel

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

        anchors.fill: parent

        model: root.model

        delegate: TaskListViewDelegate {
            objectName: "task" + index

            task: modelData
            //text: title
        }
    }

    Label {
        id: noTasksLabel
        objectName: "noTasksLabel"

        anchors.centerIn: parent

        visible: root.model.length === 0
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
}
