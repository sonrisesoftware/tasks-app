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

Item {
    id: root

    property string labelText: text
    property var text

    property bool editing
    property bool editable

    onEditingChanged: {
        if (editing)
            textField.focus = true
    }

    property bool parentEditing

    onParentEditingChanged: {
        if (parentEditing)
            edit()
    }

    height: editing
            ? textField.height
            : label.height

    property alias fontSize: label.fontSize
    property alias placeholderText: textField.placeholderText
    property bool bold

    signal doneEditing()

    Label {
        id: label

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        font.bold: root.labelText != "" ? root.bold : false
        font.italic: root.labelText === ""
        elide: Text.ElideRight
        visible: !(editing || parentEditing)
        text: root.labelText != "" ? root.labelText : root.placeholderText
    }

    property bool customClicking: false

    function edit() {
        if (editable)
            editing = true
            textField.forceActiveFocus()
    }

    function done() {
        textField.focus = false
    }

    MouseArea {
        visible: !parent.customClicking
        anchors.fill: parent

        onClicked: {
            edit()
        }
    }

    TextField {
        id: textField

        anchors {
            left: parent.left
            right: okButton.visible ? okButton.left : parent.right
            rightMargin: okButton.visible ? units.gu(1) : 0
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
                root.text = text
            } else {
                text = root.text
            }
            doneEditing()
        }

        onCursorVisibleChanged: {
            if (cursorVisible === false)
                done()
        }

        Keys.onEscapePressed: done()

        onAccepted: done()
    }

    Button {
        id: okButton
        visible: editing && !parentEditing

        anchors {
            right: parent.right
            top: textField.top
            bottom: textField.bottom
        }

//        gradient: Gradient {
//            GradientStop {
//                position: 0
//                color: backgroundColor
//            }

//            GradientStop {
//                position: 1
//                color: footerColor
//            }
//        }

        text: i18n.tr("Apply")
        onClicked: {
            done()
        }
    }
}
