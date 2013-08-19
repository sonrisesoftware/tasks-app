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
import "../components"

Flickable {
    id: root

    property var task

    property bool editing: false
    property bool creating: false

    contentHeight: column.height
    contentWidth: width

    clip: true

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
        }

        Item {
            height: headerItem.height + descriptionTextArea.height + units.gu(6)
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
                        rightMargin: completedCheckBox.visible ? units.gu(2) : 0
                    }

                    fontSize: "large"
                    bold: true
                    text: task.name
                    placeholderText: i18n.tr("Title")
                    parentEditing: root.editing

                    onTextChanged: task.name = text
                }

                CheckBox {
                    id: completedCheckBox
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }

                    visible: !creating

                    checked: task.completed
                    onCheckedChanged: task.completed = checked
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

                onFocusChanged: focus ? __styleInstance.color = Theme.palette.normal.overlayText : __styleInstance.color = "white"

                text: task.description
                placeholderText: i18n.tr("Description")

                onTextChanged: task.description = text
            }
        }

        ThinDivider {}

    //    Checklist {
    //        visible: task.hasChecklist
    //        task: root.task

    //        width: parent.width
    //    }

        Header {
            text: i18n.tr("Options")
        }

    //    Standard {
    //        visible: !task.hasChecklist

    //        text: i18n.tr("Add Checklist")
    //        onClicked: task.hasChecklist = true
    //    }

        ValueSelector {
            id: prioritySelector

            text: i18n.tr("Priority")

    //        Row {
    //            spacing: units.gu(1)

    //            anchors {
    //                left: parent.left
    //                leftMargin: units.gu(2)
    //                top: parent.top
    //                topMargin: units.gu(1.5)
    //            }

    //            UbuntuShape {
    //                color: labelColor(task.label)
    //                width: units.gu(3)
    //                height: width
    //                anchors.verticalCenter: parent.verticalCenter
    //            }

    //            Label {
    //                anchors.verticalCenter: parent.verticalCenter
    //                text: i18n.tr("Priority")
    //            }
    //        }

            selectedIndex: values.indexOf(priorityName(task.priority))

            values: {
                var values = []

                for (var i = 0; i < priorities.length; i++) {
                    values.push(priorityName(priorities[i]))
                }

                return values
            }

            onSelectedIndexChanged: {
                task.priority = priorities[selectedIndex]
            }
        }

        ValueSelector {
            id: projectSelector

            text: i18n.tr("Project")
            selectedIndex: {
                for (var i = 0; i < localProjectsModel.projects.count; i++) {
                    if (task.project === localProjectsModel.projects.get(i).modelData)
                        return i
                }
                return -1
            }

            values: {
                var values = []
                for (var i = 0; i < localProjectsModel.projects.count; i++) {
                    values.push(localProjectsModel.projects.get(i).modelData.name)
                }
                values.push(i18n.tr("<i>Create New Category</i>"))
                return values
            }

            onSelectedIndexChanged: {
//                print(selectedIndex,values.length)
//                if (selectedIndex === values.length - 1) {
//                    // Create a new category
//                    PopupUtils.open(newCategoryDialog, root)
//                    selectedIndex = values.indexOf(task.category != "" ? task.category : "Uncategorized")
//                } else if (selectedIndex === values.length - 2) {
//                    task.category = ""
//                } else {
//                    task.category = values[selectedIndex]
//                }
            }
        }

        SingleValue {
            id: dueDateField

            text: i18n.tr("Due Date")

            value: task.dueDateInfo

            onClicked: PopupUtils.open(Qt.resolvedUrl("DatePicker.qml"), dueDateField, {
                                           task: task
                                       })
        }

        MultiValue {
            id: tagsSelector

            text: i18n.tr("Tags")

            values: task.tags
        }
    }
}
