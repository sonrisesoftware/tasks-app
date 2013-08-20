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
import "../ui"

Item {
    id: root

    property int count: overdue.count + today.count
    property var model: upcomingTasks

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: column.height

        clip: true

        Column {
            id: column
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
                //model: root.model
                model: filteredTasks(upcomingTasks, function(task) { return task.overdue}, "Overdue ONLY")
                delegate: TaskListItem {
                    objectName: "overdueTask" + index

                    task: modelData
                }
            }

            Header {
                text: i18n.tr("Today")
                visible: today.count > 0
            }

            Repeater {
                id: today
                //model: upcomingTasks
                model: filteredTasks(upcomingTasks, function(task) { return !task.overdue}, "Upcoming ONLY")
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
        visible: count === 0

        fontSize: "large"
        text: i18n.tr("No upcoming tasks")
        opacity: 0.5
    }
}