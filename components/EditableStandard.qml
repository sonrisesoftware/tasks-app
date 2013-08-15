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

    property alias text: textField.text
    property bool editing
    property bool bold
    property alias fontSize: label.fontSize

    property var control

    onEditingChanged: {
        if (editing)
            textField.focus = true
    }

    property bool parentEditing

    onParentEditingChanged: editing = parentEditing

    property alias placeholderText: textField.placeholderText

    onClicked: {
        editing = true
    }


    Label {
        id: label

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: control == null ? parent.right : control.left
            rightMargin: control == null ? units.gu(2) : units.gu(1)
            verticalCenter: parent.verticalCenter
        }

        font.bold: root.text != "" ? root.bold : false
        font.italic: root.text === ""
        elide: Text.ElideRight
        visible: !(editing || parentEditing)
        text: root.text != "" ? root.text : root.placeholderText
    }

    TextField {
        id: textField

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: control == null ? parent.right : control.left
            rightMargin: control == null ? units.gu(2) : units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        Component.onCompleted: __styleInstance.color = "white"

        //width: Math.min(parent.width, units.gu(50))

        font.bold: root.bold
        visible: editing || parentEditing

        onFocusChanged:  {
            focus ? __styleInstance.color = Theme.palette.normal.overlayText : __styleInstance.color = "white"

            if (focus === false) {
                root.editing = false
            }
        }

        onAccepted: editing = false
    }
}
