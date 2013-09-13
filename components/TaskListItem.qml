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
import Ubuntu.Components.Themes.Ambiance 0.1
import "../ui"

Empty {

    id: root

    property var task

    height: opacity === 0 ? 0 : implicitHeight

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    opacity: show ? 1 : 0

    clip: true

    property bool show: true

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    CheckBox {
        id: doneCheckBox

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
        }

        checked: task.completed
        __acceptEvents: task.canComplete && task.editable
        visible: task.canEdit("completed")

        onCheckedChanged: {
            task.completed = checked
            checked = Qt.binding(function() {return task.completed})
        }
        style: SuruCheckBoxStyle {}
    }

    Label {
        anchors.centerIn: doneCheckBox
        text: task.checklist.percent + "%"
        visible: !task.canComplete && !task.completed
    }

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: doneCheckBox.visible ? doneCheckBox.right : parent.left
            leftMargin: doneCheckBox.visible ? units.gu(1) : units.gu(2)
            rightMargin: units.gu(1)
            right: taskOptions.left
        }

        Label {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight
            text: task.name

            //font.bold: task.priority !== "low"
            color: selected ? UbuntuColors.orange : /*task.priority === "low" ? */Theme.palette.selected.backgroundText/* : priorityColor(task.priority)*/
            fontSize: "medium"
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            color: task.overdue ? priorityColor("high") : task.isDueToday() ? priorityColor("medium") : Theme.palette.normal.backgroundText
            fontSize: "small"
            //font.italic: true
            text: task.subText
            visible: text !== ""
            elide: Text.ElideRight
        }
    }

    Row {
        id: tags

        spacing: units.gu(0.7)
        clip: true

        anchors {
            top: parent.top
            left: doneCheckBox.visible ? doneCheckBox.right : parent.left
            leftMargin: doneCheckBox.visible ? units.gu(1) : units.gu(2)
            rightMargin: units.gu(2)
            right: parent.right
        }

        Repeater {
            model: task.tags

            delegate: Rectangle {
                anchors {
                    top: parent.top
                    topMargin: -units.gu(0.4)
                }

                width: units.gu(4)
                height: units.gu(1)

                color: labelColor(modelData)
                radius: units.gu(0.4)
                antialiasing: true
            }
        }
    }

    Row {
        id: taskOptions
        spacing: units.gu(1)

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)
        }

        UbuntuShape {
            id: priorityShape
            anchors.verticalCenter: parent.verticalCenter

            width: units.gu(4)
            height: width

            color: priorityColor(task.priority)
            visible: task.priority !== "low"
            //visible: false
        }

        UbuntuShape {
            image: Image {
                source: icon("toolbarIcon")
            }

            visible: task.assignedTo !== ""

            width: units.gu(4)
            height: width
        }
    }

    onClicked: {
        goToTask(task)
    }

    onPressAndHold: {
        if (task.editable)
            PopupUtils.open(taskActionsPopover, root, {
                                task: root.task
                            })
    }
}
