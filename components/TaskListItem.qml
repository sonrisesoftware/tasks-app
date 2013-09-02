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

Empty {

    id: root

    property var task

    height: opacity === 0 ? 0 : implicitHeight

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    //onHeightChanged: print("HEIGHT CHANGED:", height)

    clip: true
    opacity: show ? 1 : 0

    property bool show: true

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    UbuntuShape {
        id: priorityShape
        anchors {
            left: parent.left
            //top: parent.top
            //bottom: parent.bottom
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
        }
        width: units.gu(3)
        height: width
        color: priorityColor(task.priority)
    }

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: priorityShape.right
            margins: units.gu(1)
            right: doneCheckBox.left
        }

        Text {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight
            text: task.name

            color: selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            color: Theme.palette.normal.backgroundText
            fontSize: "small"
            font.italic: true
            text: task.subText
            visible: Qt.formatDate(task.dueDate) != ""
            elide: Text.ElideRight
        }
    }

//    Rectangle {
//        id: priority

//        anchors {
//            top: parent.top
//            left: parent.left
//            bottom: parent.bottom
//            topMargin: units.gu(1)
//            bottomMargin: units.gu(1)
//            leftMargin: units.gu(0.5)
//        }

//        radius: units.gu(0.4)
//        smooth: true

//        width: units.gu(0.8)

//        color: priorityColor(task.priority)

////        gradient: Gradient {
////            GradientStop {
////                position: 0
////                color: Qt.lighter(task.priority, 1.2)
////            }

////            GradientStop {
////                position: 1
////                color: Qt.darker(task.priority, 1.2)
////            }
////        }
//    }


    CheckBox {
        id: doneCheckBox

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)
        }

        checked: task.completed
        __acceptEvents: task.canComplete && task.editable

        onCheckedChanged: task.completed = checked
    }

    Label {
        anchors.centerIn: doneCheckBox
        text: task.checklist.percent + "%"
        visible: !task.canComplete && !task.completed
    }

    onClicked: {
        goToTask(task)
    }

    onPressAndHold: {
        if (task.ediable)
            PopupUtils.open(taskActionsPopover, root, {
                                task: root.task
                            })
    }
}
