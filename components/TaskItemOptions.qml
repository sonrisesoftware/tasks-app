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
import "../ubuntu-ui-extras"

Column {
    id: root

    property var task

    Standard {
        visible: !task.hasChecklist
        enabled: task.canEdit("checklist")

        text: i18n.tr("Add Checklist...")
        onClicked: {
            task.checklist.add(i18n.tr("New Item"))
        }
    }

    ValueSelector {
        id: prioritySelector

        text: i18n.tr("Priority")
        enabled: task.canEdit("priority")

        selectedIndex: getSelectedPriority()

        function getSelectedPriority() {
            return values.indexOf(priorityName(task.priority))
        }

        values: {
            var values = []

            for (var i = 0; i < priorities.length; i++) {
                values.push(priorityName(priorities[i]))
            }

            return values
        }

        onSelectedIndexChanged: {
            task.priority = priorities[selectedIndex]
            selectedIndex = Qt.binding(getSelectedPriority)
        }
    }

//    ValueSelector {
//        id: projectSelector

//        text: i18n.tr("Project")
//        selectedIndex: getSelectedProject()
//        enabled: task.editable

//        function getSelectedProject() {
//            for (var i = 0; i < localProjectsModel.projects.count; i++) {
//                if (task.project === localProjectsModel.projects.get(i).modelData)
//                    return i
//            }
//            return -1
//        }

//        values: {
//            var values = []
//            for (var i = 0; i < localProjectsModel.projects.count; i++) {
//                values.push(localProjectsModel.projects.get(i).modelData.name)
//            }
//            values.push(i18n.tr("<i>Create New Project</i>"))
//            return values
//        }

//        onSelectedIndexChanged: {
//            print(selectedIndex,values.length)
//            if (selectedIndex === values.length - 1) {
//                PopupUtils.open(newProjectDialog, root)
//                selectedIndex = values.length - 1
//            }

//            var newProject = localProjectsModel.projects.get(selectedIndex).modelData
//            if (task.project !== newProject)
//                task.moveTo(newProject)
//            selectedIndex = Qt.binding(getSelectedProject)
//        }
//    }

    SingleValue {
        id: dueDateField

        text: i18n.tr("Due Date")
        enabled: task.canEdit("dueDate")

        value: task.dueDateInfo
        visible: task.hasOwnProperty("dueDate")

        onClicked: PopupUtils.open(Qt.resolvedUrl("DatePicker.qml"), dueDateField, {
                                       task: task
                                   })
    }

    ValueSelector {
        id: repeatSelector
        text: i18n.tr("Repeat")
        visible: task.hasOwnProperty("repeat")
        enabled: task.canEdit("repeat") && task.hasDueDate

        values: [i18n.tr("Never"), i18n.tr("Daily"), i18n.tr("Weekly"), i18n.tr("Monthly"), i18n.tr("Yearly")]
        selectedIndex: getSelectedIndex()

        function getSelectedIndex() {
            if (task.repeat === "never") return 0
            else if (task.repeat === "daily") return 1
            else if (task.repeat === "weekly") return 2
            else if (task.repeat === "monthly") return 3
            else if (task.repeat === "yearly") return 4
        }

        onSelectedIndexChanged: {
            if (selectedIndex === 0) task.repeat = "never"
            else if (selectedIndex === 1) task.repeat = "daily"
            else if (selectedIndex === 2) task.repeat = "weekly"
            else if (selectedIndex === 3) task.repeat = "monthly"
            else if (selectedIndex === 4) task.repeat = "yearly"
            selectedIndex = Qt.binding(getSelectedIndex)
        }
    }

    MultiValue {
        id: tagsSelector

        text: i18n.tr("Tags")
        enabled: task.canEdit("tags")

        values: task.tags
        onClicked: PopupUtils.open(tagsPopover, tagsSelector, {task: task})
        visible: false
    }
}
