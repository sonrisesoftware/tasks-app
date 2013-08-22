/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>             *
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

Item {
    id: taskItem

    property var task

    property bool editing: false
    property bool creating: false
    property var page

    property var flickable: flickable

    Flickable {
        id: flickable
        contentHeight: column.height
        contentWidth: width

        clip: true

        anchors {
            top: parent.top
            left: sidebar.mode === "left" ? sidebar.right : parent.left
            right: sidebar.mode === "left" ? parent.right : sidebar.left
            bottom: parent.bottom
        }

        Column {
            id: column

            width: flickable.width

            Item {
//                height: textDivider.visible
//                        ? headerItem.height + descriptionTextArea.height + units.gu(6)
//                        : root.height
                height: headerItem.height + descriptionTextArea.height + units.gu(6)

//                Behavior on height {
//                    UbuntuNumberAnimation {}
//                }

                width: parent.width

                Item {
                    id: headerItem
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    height: completedCheckBox.visible
                            ? Math.max(titleLabel.height, completedCheckBox.height)
                            : titleLabel.height

                    EditableLabel {
                        id: titleLabel

                        anchors.verticalCenter: parent.verticalCenter
                        anchors {
                            left: parent.left
                            right: completedCheckBox.visible ? completedCheckBox.left : parent.right
                            rightMargin: completedCheckBox.visible ? units.gu(1) : 0
                        }

                        fontSize: "large"
                        bold: true
                        text: task.name
                        placeholderText: i18n.tr("Title")
                        parentEditing: taskItem.editing

                        onTextChanged: {
                            if (task.name !== text) {
                                task.name = text
                                text = Qt.binding(function() { return task.name })
                            }
                        }
                    }

                    CheckBox {
                        id: completedCheckBox
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }

                        visible: !creating && !titleLabel.editing
                        __acceptEvents: task.canComplete


                        checked: task.completed
                        onCheckedChanged: task.completed = checked
                    }

                    Label {
                        anchors.centerIn: completedCheckBox
                        text: task.percent + "%"
                        visible: !task.canComplete && !task.completed && completedCheckBox.visible
                    }
                }

                TextArea {
                    id: descriptionTextArea
                    anchors {
                        top: headerItem.bottom
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    Component.onCompleted: __styleInstance.color = "white"

                    onFocusChanged: {
                        __styleInstance.color = (focus ? Theme.palette.normal.overlayText : "white")
                    }

                    text: task.description
                    placeholderText: i18n.tr("Description")

                    onTextChanged: task.description = text
                }
            }

            ThinDivider {
                id: textDivider
                visible: task.hasChecklist
            }

            Checklist {
                visible: task.hasChecklist
                task: taskItem.task

                width: parent.width
            }

            Header {
                text: i18n.tr("Options")
                visible: !sidebar.expanded
            }

            TaskItemOptions {
                visible: !sidebar.expanded
                width: parent.width
                task: taskItem.task
            }
        }
    }

    Scrollbar {
        flickableItem: flickable
    }

    Sidebar {
        id: sidebar
        mode: "right"
        expanded: wideAspect

        Header {
            id: optionsHeader
            text: i18n.tr("Options")
        }

        Flickable {
            id: optionsFlickable
            anchors {
                top: optionsHeader.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            clip: true

            contentHeight: options.height
            contentWidth: width

            TaskItemOptions {
                id: options
                width: parent.width

                task: taskItem.task
            }
        }

        Scrollbar {
            flickableItem: optionsFlickable
        }
    }
}
