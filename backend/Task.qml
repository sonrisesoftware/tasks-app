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

    property int index
    property var project

    property string name
    property string description
    property date creationDate: new Date()
    property date dueDate
    property string repeat: "never" // or "daily", "weekly", "monthly"
    property bool completed
    property date completionDate
    property string priority: "low"
    property var tags: []
    
    onCompletedChanged: {
        if (completed) {
            completionDate = new Date()
        }
    }

    property bool upcoming: overdue || isDueToday()

    property bool overdue: {
        return dateIsBefore(dueDate, new Date())
    }

    property string subText: task.completed
                             ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                             : Qt.formatDate(task.dueDate) === ""
                               ? i18n.tr("No due date")
                               : task.overdue
                                 ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                                 : i18n.tr("Due %1").arg(formattedDate(task.dueDate))

    property string dueDateInfo: task.completed
                                 ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                                 : Qt.formatDate(task.dueDate) === ""
                                   ? i18n.tr("None")
                                   : task.overdue
                                     ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                                     : formattedDate(task.dueDate)


    function save() {
        return {
            name: name,
            description: description,
            creationDate: creationDate,
            dueDate: dueDate,
            repeat: repeat,
            completed: completed,
            completionDate: completionDate,
            priority: priority,
            tags: tags
        }
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

    function isDueToday() {
        var today = new Date()

        return dueDate.getFullYear() === today.getFullYear() &&
                dueDate.getMonth() === today.getMonth() &&
                dueDate.getDate() === today.getDate()
    }

    function remove() {
        project.removeTask(task)
    }
}
