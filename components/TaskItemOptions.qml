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
import "../ui"

Column {
    id: root

    property var task

    Header {
        text: i18n.tr("Options")
    }

    Standard {
        visible: !task.hasChecklist && task.supportsField("checklist")
        enabled: task.editable

        text: i18n.tr("Add Checklist...")
        onClicked: {
            task.checklist.add(i18n.tr("New Item"))
        }
    }

    Standard {
        id: inProgress

        text: i18n.tr("In Progress")
        enabled: task.editable
        visible: task.supportsField("assignedTo") && !task.project.backend.supportsMultipleUsers
        control: CheckBox {
            checked: task.isAssignedToMe()
            style: SuruCheckBoxStyle {}

            onCheckedChanged: {
                if (checked) {
                    task.assignToMyself()
                } else {
                    task.assignedTo = ""
                }

                checked = Qt.binding(function() { return task.isAssignedToMe() })
            }
        }
    }

    Standard {
        id: assignedTo

        enabled: task.editable
        visible: task.supportsField("assignedTo") && task.project.backend.supportsMultipleUsers

        text: i18n.tr("Assigned To")
        UbuntuShape {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(2)
            }

            image: Image {
                source: icon("toolbarIcon")
            }
            visible: task.assignedTo !== ""

            width: units.gu(4)
            height: width
        }
        onClicked: PopupUtils.open(Qt.resolvedUrl("UserPopover.qml"), assignedTo, {task: task})
    }

    ValueSelector {
        id: prioritySelector

        text: i18n.tr("Priority")
        enabled: task.editable
        visible: task.supportsField("priority")

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

    SingleValue {
        id: dueDateField

        text: i18n.tr("Due Date")
        visible: task.supportsField("dueDate")
        enabled: task.editable

        value: task.dueDateInfo

        onClicked: PopupUtils.open(dueDatePicker, dueDateField, {task: root.task})
    }

//    ValueSelector {
//        id: repeatSelector
//        text: i18n.tr("Repeat")
//        visible: task.supportsField("repeat")
//        enabled: task.editable && task.hasDueDate

//        values: [i18n.tr("Never"), i18n.tr("Daily"), i18n.tr("Weekly"), i18n.tr("Bi-weekly"), i18n.tr("Monthly"), i18n.tr("Yearly")]
//        selectedIndex: getSelectedIndex()

//        function getSelectedIndex() {
//            if (task.repeat === "never") return 0
//            else if (task.repeat === "daily") return 1
//            else if (task.repeat === "weekly") return 2
//            else if (task.repeat === "biweekly") return 3
//            else if (task.repeat === "monthly") return 4
//            else if (task.repeat === "yearly") return 5
//        }

//        onSelectedIndexChanged: {
//            if (selectedIndex === 0) task.repeat = "never"
//            else if (selectedIndex === 1) task.repeat = "daily"
//            else if (selectedIndex === 2) task.repeat = "weekly"
//            else if (selectedIndex === 3) task.repeat = "biweekly"
//            else if (selectedIndex === 4) task.repeat = "monthly"
//            else if (selectedIndex === 5) task.repeat = "yearly"
//            selectedIndex = Qt.binding(getSelectedIndex)
//        }
//    }

    Header {
        text: i18n.tr("Labels")
        //visible: task.supportsField("tags")
    }

    Repeater {
        //model: task.supportsField("tags") ? ["yellow", "red", "purple", "orange", "green", "blue"] : []
        model: ["yellow", "red", "purple", "orange", "green", "blue"]

        delegate: Standard {
            height: units.gu(5)
            //enabled: task.editable
            enabled: task.canEdit("tags")

            UbuntuShape {
                id: colorShape
                height: units.gu(3)
                width: height//task.project.getTag(modelData) === modelData ? units.gu(15) : height
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }
                color: labelColor(modelData)
            }

            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: colorShape.right
                    margins: units.gu(1)
                }

                width: parent.width - units.gu(9)

                text: task.project.getTag(modelData)
                //visible: task.project.getTag(modelData) !== modelData
            }

            control: CheckBox {
                height: units.gu(3.5)
                width: height
                checked: task.hasTag(modelData)
                style: SuruCheckBoxStyle {}

                //__acceptEvents: task.canEdit("tags")

                onClicked: {
                    if (task.hasTag(modelData)) {
                        task.removeTag(modelData)
                    } else {
                        task.addTag(modelData)
                    }

                    checked = Qt.binding(function() {
                        return task.hasTag(modelData)
                    })
                }
            }
        }
    }

//    MultiValue {
//        id: tagsSelector

//        text: i18n.tr("Tags")
//        //enabled: task.canEdit("tags")

//        values: [task.tagsString]
//        //onClicked: PopupUtils.open(tagsPopover, tagsSelector, {task: task})
//        //visible: false
//    }

    Component {
        id: dueDatePicker
        DateSheet {
            property var task

            onConfirmClicked: {
                task.dueDate = date.dueNext()
            }
        }
    }
}
