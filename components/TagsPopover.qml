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
import "../ubuntu-ui-extras" as Extra

Popover {
    id: root

    property var task

    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Repeater {
            id: repeater
            model: task.project.tags

            delegate: Standard {
                //FIXME: Hack because of Suru theme!
                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        margins: units.gu(2)
                    }

                    text: modelData
                    fontSize: "medium"
                    color: selected ? UbuntuColors.orange : Theme.palette.normal.overlayText
                }

                removable: true

                backgroundIndicator: Extra.ListItemBackground {
                    text: "Delete"
                    fontColor: Theme.palette.normal.overlayText
                    iconSource: getIcon("delete")
                    state: swipingState
                }

                onItemRemoved: {
                    var tags = task.project.tags
                    tags.splice(task.tags.indexOf(modelData), 1)
                    task.project.tags = tags
                }

//                selected: task.tags.indexOf(modelData) !== -1

//                onClicked: {
//                    if (selected) {
//                        var tags = task.tags
//                        tags.splice(task.tags.indexOf(modelData), 1)
//                        task.tags = tags
//                    } else {
//                        var tags = task.tags
//                        tags.push(modelData)
//                        task.tags = tags.sort()
//                    }
//                }

                control: CheckBox {
                    checked: task.tags.indexOf(modelData) !== -1

                    onClicked: {
                        var selected = task.tags.indexOf(modelData) !== -1
                        if (selected) {
                            var tags = task.tags
                            tags.splice(task.tags.indexOf(modelData), 1)
                            task.tags = tags
                        } else {
                            var tags = task.tags
                            tags.push(modelData)
                            task.tags = tags.sort()
                        }

                        checked = Qt.binding(function() {
                            return task.tags.indexOf(modelData) !== -1
                        })
                    }
                }

                showDivider: index < repeater.count - 1
            }
        }

        Divider {
            visible: repeater.count > 0
        }

        Empty {

            TextField {
                id: tagField
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: addButton.left
                    margins: units.gu(2)
                    rightMargin: units.gu(1)
                }

                placeholderText: i18n.tr("New Tag")

                onAccepted: addButton.clicked()
            }

            Button {
                id: addButton
                anchors {
                    top: tagField.top
                    bottom: tagField.bottom
                    right: parent.right
                    rightMargin: units.gu(2)
                }

                text: i18n.tr("Add")
                enabled: tagField.acceptableInput

                onClicked: {
                    var list = task.project.tags
                    list.push(tagField.text)
                    task.project.tags = list.sort()
                    var tags = task.tags
                    tags.push(tagField.text)
                    task.tags = tags.sort()

                    tagField.text = ""
                }
            }
        }
    }
}
