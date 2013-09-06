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
    id: list

    /* Properties that define how the list works */

    property string docId               // The document ID used by U1db and optionally by other storage
    property string name                // The name of the list
    property var project
    property bool editable: project.editable
    property var customUploadFields

    property var upcomingTasks: filter(tasks, function(task) {
        return task.upcoming
    }, "Upcoming tasks")
    property int uncompletedCount: count(tasks, function(task) {
        return !task.completed
    })

    property int nextDocId
    property var taskComponent

    onNextDocIdChanged: document.set("nextDocId", nextDocId)

    onNameChanged:  fieldChanged("name", name)

    property bool updating: false       // Used to prevent sending changes to remote backend
                                        // when loading changes from the remote or local backend

    function fieldChanged(name, value) {
        if (!updating)
            document.set(name, value)
    }

    property var tasks: ListModel {
        id: tasks
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    function reloadFields() {
        //print("Reloading list", name)
        updating = true

        name = document.get("name", "")

        if (customUploadFields)
            customUploadFields()

        updating = false
        //print("Done.")
    }

    /* U1db Storage */

    property var document: Document {
        id: document
        name: "List"
        parent: project.document
        docId: list.docId
    }

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
        args.list = list

        var task = taskComponent.createObject(list, args)

        if (task === null) {
            console.log("Unable to create:", newName)
        }

        return task
    }

    // This adds a task to the model
    function internal_addTask(task) {
        if (task.list !== list)
            task.list = list
        if (task.docId === "")
            task.docId = nextDocId++
        tasks.append({modelData: task})
        //print("TASKS", tasks.count)
    }

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

    function remove() {
        project.removeList(list)
        docId = ""
    }
}
