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

    //onHeightChanged: print("HEIGHT CHANGED:", height)

    clip: true
    opacity: show ? 1 : 0

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

        onCheckedChanged: task.completed = checked
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
            left: doneCheckBox.right
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
            right: taskOptions.left
        }

        Label {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight
            text: task.name

            color: selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
            fontSize: "medium"
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            color: Theme.palette.normal.backgroundText
            fontSize: "small"
            //font.italic: true
            text: task.subText
            visible: text !== ""
            elide: Text.ElideRight
        }
    }

    Row {
        id: taskOptions

        spacing: units.gu(1)

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
        }

//        Image {
//            source: task.priority === "high" ? icon("favorite-selected") : icon("favorite-unselected")
//            width: units.gu(4)
//            height: width

//        }

        UbuntuShape {
            id: priorityShape
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: units.gu(3)
            height: width
            color: task.priority !== "low" ? priorityColor(task.priority) : Qt.rgba(0.2,0.2,0.2,0.2)

            Behavior on color {
                ColorAnimation {
                    duration: 250
                }
            }

            //visible: task.priority !== "low"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (task.priority === "high") {
                        task.priority = "low"
                    } else {
                        task.priority = "high"
                    }
                }
            }
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
