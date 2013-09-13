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
import U1db 1.0 as U1db

Item {
    id: project

    /* Properties that define how the project works */

    property string docId               // The document ID used by U1db and optionally by other storage
    property string name                // The name of the project
    property string description         // The description of the project
    property bool archived              // Is the project archived?
    property var tags                   // The possible tags
    property bool special               // Is this a special project that lives under Upcoming, such as Uncategorized?
    property bool editable: backend.editable
    property var backend

    property var assignedTasks: filter(tasks, function(task) {
        return task.isAssignedToMe() && !task.completed
    }, "Upcoming tasks")
    property var upcomingTasks: filter(tasks, function(task) {
        return task.upcoming
    }, "Upcoming tasks")
    property int uncompletedCount: name === "Done" ? 0 : filteredCount(tasks, function(task) {
        return !task.completed
    })

    property ListModel tasks: ListModel {

    }

    property var nonEditableFields: []
    property var invalidActions: []

    function getTag(color) {
        return tags.hasOwnProperty(color) && tags[color] !== ""
                ? tags[color]
                : color.substring(0,1).toUpperCase() + color.substring(1)
    }

    function setTag(color, name) {
        print(color, "=", name)
        var list = tags
        list[color] = name
        tags = list
    }

    function supportsAction(name) {
        return editable && invalidActions.indexOf(name) === -1
    }

    function canEdit(name) {
        return editable && nonEditableFields.indexOf(name) === -1
    }

    property int nextDocId: 0
    property var taskComponent: Component {

        GenericTask {

        }
    }

    property var customUploadFields

    onNextDocIdChanged: document.set("nextDocId", nextDocId)

    onNameChanged:  fieldChanged("name", name)
    onDescriptionChanged: fieldChanged("description", description)
    onArchivedChanged: fieldChanged("archived", archived)
    onSpecialChanged: fieldChanged("special", special)
    onTagsChanged: fieldChanged("tags", tags)

    property bool updating: false       // Used to prevent sending changes to remote backend
                                        // when loading changes from the remote or local backend

    function fieldChanged(name, value) {
        if (!updating)
            document.set(name, value)
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    function reloadFields() {
        //print("Reloading project", name)
        updating = true

        name = document.get("name", "")
        description = document.get("description", "")
        archived = document.get("archived", false)
        special = document.get("special", false)
        tags = document.get("tags", {})

        if (customUploadFields)
            customUploadFields()

        updating = false
        //print("Done.")
    }

    /* U1db Storage */

    property var document: Document {
        id: document
        name: "Project"
        parent: backend.database
        docId: project.docId
    }

    /* U1db Storage */

    function loadU1db() {
        nextDocId = document.get("nextDocId", 0)
        reloadFields()

        var list = document.listDocs()
        //print("Child tasks:", list)

        for (var i = 0; i < list.length; i++) {
            loadTaskU1db(list[i])
        }
    }

    /* Creation of new tasks */

    // This is the front-end to creating new tasks
    function newTask(name) {
        //print("Adding new task...")
        var task = createTask({
                          docId: nextDocId++
                      })
        task.name = name
        internal_addTask(task)
        return task
    }

    // For loading a task from U1db
    function loadTaskU1db(docId) {
        var task = createTask({
                                  docId: docId
                              })
        internal_addTask(task)
        task.loadU1db()
        return task
    }

    // Creates a new task object
    function createTask(args) {
        if (args === undefined)
            args = {}

        if (args.docId === "") args.docId = nextDocId++
        args.project = project

        var task = taskComponent.createObject(project, args)

        if (task === null) {
            console.log("Unable to create:", newName)
        }

        return task
    }

    // This adds a task to the model
    function internal_addTask(task) {
        if (task.project !== project)
            task.project = project
        if (task.docId === "")
            task.docId = nextDocId++
        tasks.append({modelData: task})
        //print("TASKS", tasks.count)
    }

    function addTask(task) { internal_addTask(task) }

    /* Deletion of tasks */

    // This is the front-end to removing tasks
    function removeTask(task) {
        // For implementation by backend...
        internal_removeTask(task)
    }

    // This removes a task from the model
    function internal_removeTask(task) {
        print("Removing task...")
        document.remove(task.docId)
        for (var i = 0; i < tasks.count; i++) {
            if (tasks.get(i).modelData === task)
                tasks.remove(i)
        }
    }

    /* DELETION OF THE PROJECT */

    function remove() {
        //print("Deleting project...")
        backend.removeProject(project)
        docId = ""
    }
}
