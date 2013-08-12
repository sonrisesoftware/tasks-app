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
import "../ui"

Empty {

    id: root

    property Task task

    clip: true

    Label {
        id: titleLabel
        anchors {
            top: dueDateLabel.visible ? parent.top : undefined
            topMargin: units.gu(0.7)
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: dueDateLabel.visible ? undefined : parent.verticalCenter
        }

        text: task.title
        color: Theme.palette.selected.backgroundText
    }

    Label {
        id: dueDateLabel
        anchors {
            //top: titleLabel.bottom
            //topMargin: units.gu(0.2)
            bottom: parent.bottom
            bottomMargin: units.gu(0.7)
            left: parent.left
            leftMargin: units.gu(2)
        }

        //color: UbuntuColors.warmGrey
        color: Theme.palette.normal.backgroundText
        fontSize: "small"
        font.italic: true
        text: task.dueDateInfo
        visible: Qt.formatDate(task.dueDate) != ""
    }

    Rectangle {
        id: label

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            leftMargin: units.gu(0.5)
        }

        radius: units.gu(0.4)
        smooth: true

        width: units.gu(0.8)

        color: labelColor(task.label)

//        gradient: Gradient {
//            GradientStop {
//                position: 0
//                color: Qt.lighter(task.label, 1.2)
//            }

//            GradientStop {
//                position: 1
//                color: Qt.darker(task.label, 1.2)
//            }
//        }
    }


    CheckBox {
        id: doneCheckBox

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)
        }

        checked: task.completed

        onCheckedChanged: showCompletedTasks ? task.completed = checked : hideAnimation.start()

        SequentialAnimation {
            id: hideAnimation


            NumberAnimation { target: root; property: "opacity"; to: 0; duration: 500 }
            NumberAnimation { target: root; property: "height"; to: 0; duration: 250 }
            PropertyAnimation {
                target: root.task; property: "completed"; to: true
            }
        }


    }

    onClicked: {
        pageStack.push(taskViewPage, {
                           task: root.task
                       })
    }

    onPressAndHold: {
        PopupUtils.open(taskActionsPopover, root, {
                            task: root.task
                        })
    }
}
