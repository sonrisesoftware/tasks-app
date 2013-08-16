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

Page {
    id: root

    title: i18n.tr("Tasks")

    property string type: "root"

    Sidebar {
        id: sidebar
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        ListView {
            id: listView
            anchors.fill: parent
            model: categories

            clip: true

            header: Header {
                text: i18n.tr("Categories")
            }

            delegate: Standard {
                id: categoryItem

                text: modelData
                onClicked: goToCategory(modelData)

                onPressAndHold: {
                    PopupUtils.open(categoryActionsPopover, categoryItem, {
                                        category: modelData
                                    })
                }
            }

            footer: Standard {
                text: i18n.tr("Uncategorized")
                onClicked: goToCategory("")
            }
        }

        Scrollbar {
            flickableItem: listView
        }

        //width: units.gu(40)
        expanded: wideAspect
    }


    Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            left: sidebar.right
        }

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: column.height

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Header {
                    text: i18n.tr("Overdue")
                    visible: overdue.count > 0
                }

                Repeater {
                    id: overdue
                    model: filteredTasks(function(task) { return task.overdue && !task.completed})
                    delegate: TaskListItem {
                        objectName: "overdueTask" + index

                        task: modelData
                    }
                }

                Header {
                    text: i18n.tr("Upcoming")
                    visible: upcoming.count > 0
                }

                Repeater {
                    id: upcoming
                    model: filteredTasks(function(task) { return task.isToday() && !task.completed })
                    delegate: TaskListItem {
                        objectName: "upcomingTask" + index

                        task: modelData
                    }
                }
            }
        }

        Scrollbar {
            flickableItem: flickable
        }

        Label {
            anchors.centerIn: parent
            visible: upcoming.count == 0 && overdue.count == 0

            fontSize: "large"
            text: i18n.tr("No upcoming tasks")
            opacity: 0.5
        }
    }

    tools: ToolbarItems {
        back: null

        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("New")

            onTriggered: {
                PopupUtils.open(newCategoryDialog, caller)
            }
        }

        ToolbarButton {
            iconSource: icon("graphs")
            text: i18n.tr("Statistics")
            onTriggered: {
                pageStack.push(statisticsPage)
            }
        }
    }

    Component {
        id: categoryActionsPopover

        ActionSelectionPopover {
            property string category

            actions: ActionList {
                Action {
                    text: i18n.tr("Rename")
                    onTriggered: {
                        PopupUtils.open(renameCategoryDialog, caller, {
                                            category: category
                                        })
                    }
                }

                Action {
                    text: i18n.tr("Delete")
                    onTriggered: {
                        removeCategory(category)
                    }
                }
            }
        }
    }
}
