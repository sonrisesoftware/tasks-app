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
    property var project
    property bool editable: project.editable
    property var customUploadFields
    property var nonEditableFields: []
    property var invalidActions: []

    function supportsAction(name) {
        return editable && invalidActions.indexOf(name) === -1
    }

    function supportsField(name) {
        return nonEditableFields.indexOf(name) === -1
    }

    function canEdit(name) {
        return editable && nonEditableFields.indexOf(name) === -1
    }

    /* Properties describing the task */

    property string name
    property string description
    property date creationDate
    property date dueDate
    property string repeat: "never" // or "daily", "weekly", "monthly", "yearly"
    property bool completed
    property date completionDate
    property string priority: "low"
    property var tags
    property var comments
    property bool createdRepeat
    property string assignedTo

    Component.onCompleted: {
        creationDate = document.get("creationDate", new Date())
    }

    onNameChanged:  fieldChanged("name", name)
    onDescriptionChanged: fieldChanged("description", description)
    onCreationDateChanged: fieldChanged("creationDate", creationDate)
    onDueDateChanged: fieldChanged("dueDate", dueDate)
    onRepeatChanged: fieldChanged("repeat", repeat)
    onCreatedRepeatChanged: fieldChanged("createdRepeat", createdRepeat)
    onCompletedChanged: {
        fieldChanged("completed", completed)
        updateRepeat()
    }
    onCompletionDateChanged: fieldChanged("completionDate", completionDate)
    onPriorityChanged: fieldChanged("priority", priority)
    onTagsChanged: fieldChanged("tags", tags)
    onCommentsChanged: fieldChanged("comments", comments)
    onAssignedToChanged: fieldChanged("assignedTo", assignedTo)
    //TODO: Add others...

    property bool updating: false       // Used to prevent sending changes to remote backend
                                        // when loading changes from the remote or local backend

    function fieldChanged(name, value) {
        //print("FIELD CHANGED", name, "TO", value, updating)
        if (!updating)
            document.set(name, value)
    }


    property Checklist checklist: Checklist {

    }

    property var updateChecklistStatus

    property int relevence: priority === "low" ? 0 : priority === "medium" ? 1 : 2

    property bool hasChecklist: checklist.length > 0

    property bool canComplete: true//!hasChecklist

    function toJSON() {
        return {
            name: name,
            description: description,
            creationDate: creationDate,
            dueDate: dueDate,
            repeat: repeat,
            completed: completed,
            completionDate: completionDate,
            priority: priority,
            tags: tags ? tags.slice() : undefined,
            checklist: checklist.save(),
            assignedTo: assignedTo
        }
    }

    function updateRepeat() {
        if (completed) {
            // If the task has never been completed before
            // Then create the repeat of it
            if (!createdRepeat && repeat !== "never") {
                var json = toJSON()

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

                if (repeat !== "never") {
                    if (project === undefined)
                        console.log("Unable to create repeating task!")
                    else {
                        print("Adding new REPEAT task...")
                        json.completed = false
                        var docId = project.nextDocId++
                        project.document.children[docId] = json
                        project.loadTaskU1db(docId)
                    }

                    createdRepeat = true
                }
            }

            completionDate = new Date()
        }
    }

    /* U1db Storage */

    property var document: Document {
        id: document
        name: "Task"
        docId: task.docId
        parent: project.document
    }

    function reloadFields() {
        updating = true

        name = document.get("name", "")
        description = document.get("description", "")
        creationDate = document.get("creationDate", new Date())
        dueDate = document.get("dueDate", new Date(""))
        repeat = document.get("repeat", "never")
        createdRepeat = document.get("createdRepeat", false)
        completed = document.get("completed", false)
        completionDate = document.get("completionDate", new Date(""))
        priority = document.get("priority", "low")
        tags = document.get("tags", [])
        assignedTo = document.get("assignedTo", "")
        checklist.load(document.get("checklist", {}))

        if (customUploadFields)
            customUploadFields()

        updating = false
    }

    Component.onDestruction: saveU1db()

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

    property bool hasDueDate: Qt.formatDate(task.dueDate) !== ""

    property string tagsString: {
        if (tags === undefined)
            return ""

        var list = []
        for (var i = 0; i < tags.length; i++) {
            list.push(project.getTag(tags[i]))
        }
        return list.join(", ")
    }

    property string subText: task.completed
                             ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                             : hasDueDate ? task.overdue
                                            ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                                            : i18n.tr("Due %1").arg(formattedDate(task.dueDate))
                                          : ""//task.tags ? task.tags.join(", ") : ""

    property string dueDateInfo: task.completed
                                 ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                                 : Qt.formatDate(task.dueDate) === ""
                                   ? i18n.tr("None")
                                   : task.overdue
                                     ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                                     : formattedDate(task.dueDate)

    function hasTag(name) {
        if (tags === undefined) return false
        else return tags.indexOf(name) !== -1
    }

    function addTag(name) {
        if (task.tags === undefined) task.tags = []

        var tags = task.tags
        tags.push(name)
        task.tags = tags.sort()
    }

    function removeTag(name) {
        if (task.tags === undefined) task.tags = []

        if (!hasTag(name)) return

        var tags = task.tags
        tags.splice(task.tags.indexOf(name), 1)
        task.tags = tags
    }

    function isAssignedToMe() {
        return project.backend.isMyself(task.assignedTo)
    }

    function assignToMyself() {
        print("Claiming...")
        assignedTo = project.backend.userName
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

    function isDueTomorrow() {
        var tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)

        return dueDate.getFullYear() === tomorrow.getFullYear() &&
                dueDate.getMonth() === tomorrow.getMonth() &&
                dueDate.getDate() === tomorrow.getDate()
    }

    function isDueThisWeek() {
        var date = new Date()
        date.setDate(date.getDate() + 7)

        return dateIsBeforeOrSame(dueDate, date)
    }

    function remove() {
        project.removeTask(task)
        docId = ""
    }

    function canMoveToProject(project) {
        return task.supportsAction("delete") && task.project.supportsAction("addTask")
    }

    function moveToProject(project) {
        if (project === task.project) return

        remove()
        //print(JSON.stringify(database.save()))
        project.addTask(task)
        //print(JSON.stringify(database.save()))
    }

    function matches(text) {
        text = text.toUpperCase()
        return task.name.toUpperCase().indexOf(text) !== -1 || task.description.toUpperCase().indexOf(text) !== -1
    }
}

