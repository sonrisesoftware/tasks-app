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

QtObject {
    id: task

    function toJSON() {
        return {
            title: title,
            contents: contents,
            dueDate: dueDate,
            creationDate: creationDate,
            completed: completed,
            completionDate: completionDate,
            tag: tag
        }
    }

    property string title
    property string contents
    property date dueDate
    property date creationDate
    property bool completed
    property date completionDate
    property color tag: "transparent"

    property bool flagged
    
    onCompletedChanged: {
        if (completed) {
            completionDate = new Date()
        }
    }

    // This is the weighted importance based on age,
    // due date, and high
    property int importance: {
        var score = 0

        if (completed) return 0

        if (flagged) score += 50

        if (overdue) score += 100

        return score
    }

    property bool overdue: {
        var today = new Date()
        today.setHours(0)
        today.setMinutes(0)
        today.setSeconds(0)
        print(today)
        print(dueDate)
        return dueDate.getFullYear() < today.getFullYear() ||
                dueDate.getFullYear() === today.getFullYear() && dueDate.getMonth() < today.getMonth() ||
                dueDate.getFullYear() === today.getFullYear() && dueDate.getMonth() === today.getMonth()
                        && dueDate.getDate() < today.getDate()
    }

    property string dueDateInfo: task.completed
                                 ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                                 : task.overdue
                                   ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                                   : i18n.tr("Due %1").arg(formattedDate(task.dueDate))

    function isToday() {
        var today = new Date()

        return dueDate.getFullYear() === today.getFullYear() &&
                dueDate.getMonth() === today.getMonth() &&
                dueDate.getDate() === today.getDate()
    }

    function remove() {
        removeTask(task)
    }
}
