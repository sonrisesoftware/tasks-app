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

QtObject {
    id: task

    function toJSON() {
        return {
            title: task.title,
            contents: task.contents,
            dueDate: task.dueDate,
            creationDate: task.creationDate,
            completed: task.completed,
            completionDate: task.completionDate,
            label: task.label,
            category: task.category/*,
            checklist: task.checklist,
            hasChecklist: task.hasChecklist*/
        }
    }

    property string title
    property string category
    property string contents
    property date dueDate
    property date creationDate: new Date()
    property bool completed
    property date completionDate
    property string label: "green" //"transparent"
//    property var checklist: []
//    property bool hasChecklist//: true

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
        return dateIsBefore(dueDate, new Date())
    }

    property string dueDateInfo: task.completed
                                 ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                                 : Qt.formatDate(task.dueDate) === ""
                                   ? i18n.tr("None")
                                   : task.overdue
                                     ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                                     : formattedDate(task.dueDate)

    function dateIsBefore(date1, date2) {
        var ans = date1.getFullYear() < date2.getFullYear() ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() < date2.getMonth()) ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() === date2.getMonth()
                        && date1.getDate() < date2.getDate())
        return ans
    }

    function dateIsBeforeOrSame(date1, date2) {
        var ans = date1.getFullYear() < date2.getFullYear() ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() < date2.getMonth()) ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() === date2.getMonth()
                        && date1.getDate() <= date2.getDate())
        return ans
    }

    function completedBy(date) {
        return (completed && dateIsBeforeOrSame(completionDate, date)) && existedBy(date)
    }

    function notCompletedBy(date) {
        return (!completed || dateIsBefore(date, completionDate)) && existedBy(date)
    }

    function overdueBy(date) {
        return notCompletedBy(date) && dateIsBefore(dueDate, date)
    }

    function existedBy(date) {
        return dateIsBeforeOrSame(creationDate, date)
    }

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
