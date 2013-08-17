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

    property string type: category === null_category ? "upcoming" : "category"

    property string category: null_category
    property bool upcoming: category === null_category

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

            header: Column {
                width: parent.width

                CategoryListItem {
                    text: i18n.tr("Upcoming")
                    onClicked: category = null_category
                    selected: upcoming
                    count: upcomingTasks.count
                }

                Header {
                    text: i18n.tr("Categories")
                }
            }

            delegate: CategoryListItem {
                category: modelData
            }

            footer: CategoryListItem {
                category: ""
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
            bottom: addBar.top//parent.bottom
            right: parent.right
            left: sidebar.right
        }

        UpcomingTasksList {
            id: upcomingTasks

            anchors.fill: parent
            visible: upcoming
        }

        TasksList {
            id: list

            showAddBar: false
            anchors.fill: parent
            category: root.category
            visible: !upcoming
        }
    }

    QuickAddBar {
        id: addBar
        expanded: list.visible
        anchors.left: sidebar.right
    }

    tools: ToolbarItems {
        back: null

        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("Add")

            visible: sidebar.expanded && category != null_category && category != ""

            onTriggered: {
                pageStack.push(addTaskPage, { category: root.category })
            }
        }

        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("New")
            visible: sidebar.expanded

            onTriggered: {
                PopupUtils.open(newCategoryDialog, caller)
            }
        }

        ToolbarButton {
            iconSource: icon("edit")
            text: i18n.tr("Rename")
            visible: sidebar.expanded && category != null_category && category != ""

            onTriggered: {
                PopupUtils.open(renameCategoryDialog, caller, {
                                    category: category
                                })
            }
        }

        ToolbarButton {
            iconSource: icon("delete")
            text: i18n.tr("Delete")
            visible: sidebar.expanded && category != null_category && category != ""

            onTriggered: {
                PopupUtils.open(confirmDeleteCategoryDialog, root)
            }
        }

        ToolbarButton {
            text: i18n.tr("Options")
            iconSource: icon("settings")
            visible: sidebar.expanded

            onTriggered: {
                PopupUtils.open(optionsPopover, caller)
            }
        }
    }
}
