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
import "../ui"

Item {
    id: root

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
                visible: count(root.model, function(task) {
                    return task.overdue
                }) > 0
            }

            Repeater {
                id: overdue
                model: root.model
                delegate: TaskListItem {
                    objectName: "overdueTask" + index

                    show: task.overdue
                    task: modelData
                }
            }

            Header {
                text: i18n.tr("Today")
                visible: count(root.model, function(task) {
                    return task.isDueToday()
                }) > 0
            }

            Repeater {
                id: today
                model: root.model
                delegate: TaskListItem {
                    objectName: "todayTask" + index

                    show: task.isDueToday()
                    task: modelData
                }
            }

            Header {
                text: i18n.tr("Tomorrow")
                visible: count(root.model, function(task) {
                    return task.isDueTomorrow()
                }) > 0
            }

            Repeater {
                id: tomorrow
                model: root.model
                delegate: TaskListItem {
                    objectName: "tomorrowTask" + index

                    show: task.isDueTomorrow()
                    task: modelData
                }
            }

            Header {
                text: i18n.tr("This Week")
                visible: count(root.model, function(task) {
                    return !task.overdue && !task.isDueToday() && !task.isDueTomorrow() && task.isDueThisWeek()
                }) > 0
            }

            Repeater {
                id: week
                model: root.model
                delegate: TaskListItem {
                    objectName: "weekTask" + index

                    show: !task.overdue && !task.isDueToday() && !task.isDueTomorrow() && task.isDueThisWeek()
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
        visible: length(upcomingTasks) === 0

        fontSize: "large"
        text: i18n.tr("No upcoming tasks")
        horizontalAlignment: Text.AlignRight

        opacity: 0.5
    }
}
