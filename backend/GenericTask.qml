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

Item {
    id: task

    property string docId
    property var project: list.project
    property var list
    property bool editable: project.editable

    /* Properties describing the task */

    property string name
    property string description
    property date creationDate: new Date()
    property date dueDate
    property string repeat: "never" // or "daily", "weekly", "monthly", "yearly"
    property bool completed
    property date completionDate
    property string priority: "low"
    property var tags: []
    property var comments: []

    onNameChanged:  fieldChanged("name", name)
    onDescriptionChanged: fieldChanged("description", description)
    onCreationDateChanged: fieldChanged("creationDate", creationDate)
    onDueDateChanged: fieldChanged("dueDate", dueDate)
    onRepeatChanged: fieldChanged("repeat", repeat)
    onCompletedChanged: {
        fieldChanged("completed", completed)
        updateRepeat()
    }
    onCompletionDateChanged: fieldChanged("completionDate", completionDate)
    onPriorityChanged: fieldChanged("priority", priority)
    onTagsChanged: fieldChanged("tags", tags)
    onCommentsChanged: fieldChanged("comments", comments)
    //TODO: Add others...

    property bool updating: false       // Used to prevent sending changes to remote backend
                                        // when loading changes from the remote or local backend

    function fieldChanged(name, value) {
        if (!updating)
            document.set(name, value)
    }


    property Checklist checklist: Checklist {

    }


    property bool hasChecklist: checklist.length > 0

    property bool canComplete: !hasChecklist

    function updateRepeat() {
        if (completed) {
            var json = task.document.values

            // If the task has never been completed before
            // Then create the repeat of it
            if (repeat !== "never" && Qt.formatDate(task.completionDate) === "") {

                do {
                    if (repeat === "daily") {
                        json.dueDate.setDate(json.dueDate.getDate() + 1)
                    } else if (repeat === "weekly") {
                        json.dueDate.setDate(json.dueDate.getDate() + 7)
                    } else if (repeat === "monthly") {
                        json.dueDate.setMonth(json.dueDate.getMonth() + 1)
                    } else if (repeat === "yearly") {
                        json.dueDate.setYear(json.dueDate.getYear() + 1)
                    }
                } while (dateIsBeforeOrSame(json.dueDate, today))

                if (repeat !== "never")
                    if (project === undefined)
                        console.log("Unable to create repeating task!")
                    else
                        project.newTask(json)
            }

            completionDate = new Date()
        }
    }

    /* U1db Storage */

    Document {
        id: document
        docId: task.docId
        parent: list.document
    }

    function reloadFields() {
        updating = true

        name = document.get("name", "")
        description = document.get("description", "")
        creationDate = document.get("creationDate", new Date())
        dueDate = document.get("dueDate", new Date(""))
        repeat = document.get("repeat", "never")
        completed = document.get("completed", false)
        completionDate = document.get("completionDate", new Date(""))
        priority = document.get("priority", "low")
        tags = document.get("tags", [])
        checklist.load(document.get("checklist", {}))

        updating = false
    }

    function saveU1db() {
        document.set("checklist", checklist.save())
    }

    function loadU1db() {
        reloadFields()
        checklist.load(document.get("checklist"))
    }

    property bool upcoming: (overdue || isDueThisWeek()) && !completed

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

    function isDueThisWeek() {
        var date = new Date()
        date.setDate(date.getDate() + 7)

        return dateIsBeforeOrSame(dueDate, date)
    }

    function remove() {
        // Do something...
        list.removeTask(task)
    }

    function moveTo(project) {
        // TODO: Do something...
    }
}

