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
import "../ubuntu-ui-extras"

Page {
    id: root

    title: project.name//i18n.tr("Statistics")

    property string type: "statistics"
    property var project

    function totalCount(date) {
        return countTasks(function(task) {
            return task.existedBy(date)
        })
    }

    BarGraph {
        anchors.fill: parent
        colors: ["green", "red"]
        names: ["To do", "Overdue"]

        values: {
            var list = []
            var dates = []
            var max = 0
            for (var i = count - 1; i >= 0; i--) {
                var day = new Date()
                day.setDate(day.getDate() - i)
                var overdue = length(project.filteredTasks(function(task) { return task.overdueBy(day)}, "Overdue ONLY"))
                var other = length(project.filteredTasks(function(task) { return task.notCompletedBy(day) && !task.overdueBy(day)}, "Not completed"))
                var total = overdue + other
                if (total > max)
                    max = total

                list.push([other, overdue])
                dates.push(formattedDate(day))
            }
            maxValue = max + 1
            labels = dates
            return list
        }

        autoSize: true
    }

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: root.tools
                locked: true
                opened: true
            }
        }
    ]
}
