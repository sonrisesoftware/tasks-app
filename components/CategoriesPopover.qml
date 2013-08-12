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

Popover {
    id: root

    property Task task

    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Repeater {
            model: categories

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

                selected: task.category === modelData

//                control: CheckBox {
//                    checked: showCompletedTasks
//                    onCheckedChanged: saveSetting("showCompletedTasks", checked ? "true" : "false")
//                }

                onClicked: {
                    task.category = modelData
                    PopupUtils.close(root)
                }
            }
        }

        Standard {
            id: uncategorizedListItem

            //FIXME: Hack because of Suru theme!
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                text: i18n.tr("Uncategorized")
                fontSize: "medium"
                color: uncategorizedListItem.selected ? UbuntuColors.orange : Theme.palette.normal.overlayText
            }

            selected: task.category === ""

            onClicked: {
                task.category = ""
                PopupUtils.close(root)
            }
        }

        Standard {
            //FIXME: Hack because of Suru theme!
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                text: i18n.tr("<i>New Category...</i>")
                fontSize: "medium"
                color: Theme.palette.normal.overlayText
            }

            onClicked: {
                PopupUtils.close(root)
                PopupUtils.open(newCategoryDialog, null, {
                                      task: root.task
                                  })
            }

            showDivider: false
        }
    }
}
