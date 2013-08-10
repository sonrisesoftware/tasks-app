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
import "../components"

Column {
    id: root

    property Task task

    property bool editing: false
    property bool creating: false

    spacing: units.gu(2)

    Item {
        anchors {
            left: parent.left
            right: parent.right
        }

        height: completedCheckBox.visible
                ? Math.max(titleLabel.height, completedCheckBox.height)
                : titleLabel.height

        EditableLabel {
            id: titleLabel

            anchors.verticalCenter: parent.verticalCenter
            anchors {
                left: parent.left
                right: completedCheckBox.left
                rightMargin: units.gu(2)
            }

            fontSize: "large"
            bold: true
            text: task.title
            placeholderText: i18n.tr("Title")
            parentEditing: root.editing

            onTextChanged: task.title = text
        }

        CheckBox {
            id: completedCheckBox
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            checked: task.completed
            onCheckedChanged: task.completed = checked
            enabled: !creating
        }
    }

    Item {
        id: dueDateItem

        anchors {
            left: parent.left
            right: parent.right
        }

        height: Math.max(
                    labelButton.visible ? labelButton.height : 0,
                    Math.max(
                        dueDateLabel.visible ? dueDateLabel.height : 0,
                        dueDateField.visible ? dueDateField.height : 0
                    )
                )

        Label {
            id: dueDateLabel
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: labelButton.left
                rightMargin: units.gu(2)
            }

            visible: task.completed
            font.italic: true
            text: task.dueDateInfo
            elide: Text.ElideRight
        }

        Button {
            id: dueDateField
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: labelButton.left
                rightMargin: units.gu(2)
            }

            height: units.gu(4)

            visible: !task.completed
            text: task.dueDateInfo

            onClicked: PopupUtils.open(Qt.resolvedUrl("DatePicker.qml"), dueDateField, {
                                           task: task
                                       })
        }

        Button {
            id: labelButton

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            height: dueDateField.visible ? dueDateField.height : units.gu(4)

            text: labelName(task.label)

            color: labelColor(task.label)

            onClicked: PopupUtils.open(labelPopover, labelButton)
        }
    }

    TextArea {
        id: notesTextArea
        anchors {
            left: parent.left
            right: parent.right
        }

        autoSize: true
        maximumLineCount: 23

        text: task.contents
        placeholderText: i18n.tr("Notes")

        onTextChanged: task.contents = text
        readOnly: true
    }

    Item {
        width: parent.width
        height: units.gu(1)
    }

//    Checklist {
//        id: checklist

//        task: root.task
//        visible: task.hasChecklist

//        anchors {
//            left: parent.left
//            right: parent.right
//        }
//    }

    Component {
        id: labelPopover

        Popover {
            id: labelPopoverItem
            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Header {
                    text: i18n.tr("Priority")
                }

                Repeater {
                    model: labels

                    delegate: Standard {
                        text: labelName(modelData)
                        selected: task.label == modelData
                        onClicked: {
                            PopupUtils.close(labelPopoverItem)
                            task.label = modelData
                        }
                    }
                }
            }
        }
    }
}
