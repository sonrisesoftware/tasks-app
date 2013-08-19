/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
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

Empty {
    id: root

    property alias completed: checkBox.checked
    property var checklist
    property int itemIndex

    Row {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        spacing: units.gu(1)

        CheckBox {
            id: checkBox

            //width: units.gu(3)
            //height: width
            anchors.verticalCenter: parent.verticalCenter

            checked: checklist[itemIndex].completed
            onCheckedChanged: {
                checklist[itemIndex].completed = checked
            }
        }

        EditableLabel {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: editing ? parent.width - checkBox.width - deleteButton.width - parent.spacing * 2
                           : parent.width - checkBox.width - parent.spacing

            text: checklist[itemIndex].text
            onTextChanged: {
                checklist[itemIndex].text = text
            }
        }

        Button {
            id: deleteButton
            visible: label.editing
            iconSource: icon("delete")
            color: "red"
            height: label.height
            width: height
            onClicked: {
                task.checklist.splice(itemIndex,1)
                task.checklist = task.checklist
            }
        }
    }

    onClicked: label.focus = false
}
