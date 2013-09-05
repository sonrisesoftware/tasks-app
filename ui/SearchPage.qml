/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *                                                                         *
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

Page {
    id: root

    title: i18n.tr("Search")

    property string type: "search"

    Sidebar {
        id: sidebar

        Column {
            id: column
            width: parent.width

            Empty {
                TextField {
                    id: filterField

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: units.gu(1)
                    }

                    placeholderText: i18n.tr("Search...")
                }
            }

            ValueSelector {
                id: completedSelector
                text: i18n.tr("Completed")
                values: [
                    i18n.tr("Yes"),
                    i18n.tr("No"),
                    i18n.tr("Maybe")
                ]

                selectedIndex: 2
            }
        }

        expanded: wideAspect

        onExpandedChanged: {
            if (expanded) {
                filterField.text = filterBar.text
            } else {
                filterBar.text = filterField.text
            }
        }
    }

    FilterBar {
        id: filterBar
        anchors.left: sidebar.right
        expanded: !sidebar.expanded
    }


    property var filterText: sidebar.expanded ? filterField.text : filterBar.text

    TasksList {
        id: list

        anchors {
            top: filterBar.bottom
            bottom: parent.bottom
            right: parent.right
            left: sidebar.right
        }

        showAddBar: false
        tasks: allTasks
        filter: function(task) {
            var result = true
            if (!task.matches(filterText)) result = false
            if (completedSelector.selectedIndex === 0 && !task.completed) result = false
            if (completedSelector.selectedIndex === 1 && task.completed) result = false

            return result
        }
    }
}
