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
import "../ui"

Item {
    id: root

    property alias showAddBar: addBar.visible
    property var filter: function(task) {
        return !task.completed || showCompletedTasks
    }

    property string noneMessage: showingAssignedTasks && currentProject === null ? i18n.tr("No Assigned Tasks") : i18n.tr("No tasks")
    property var model: sort(tasks, sortBy)
    property var project: list ? list.project : null
    property var list
    property var tasks: currentProject === null && showingAssignedTasks ? assignedTasks : list ? list.tasks : []

    property alias addBarColor: addBar.color

    property var flickable: taskListView
    property alias header: taskListView.header

    ListView {
        id: taskListView
        objectName: "taskListView"

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
            show: filter(task)
        }
    }

    Scrollbar {
        flickableItem: taskListView
    }

    QuickAddBar {
        id: addBar
        anchors.bottomMargin: 0
        height: expanded ? implicitHeight : 0
    }

    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: addBar.top
        }

        Label {
            id: noTasksLabel
            objectName: "noTasksLabel"

            anchors.centerIn: parent

            visible: filteredCount(model, filter) === 0
            opacity: 0.5

            fontSize: "large"

            text: root.noneMessage
        }
    }
}
