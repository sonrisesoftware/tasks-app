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
import U1db 1.0 as U1db
import ".."

GenericList {
    id: list

    property string listID
    editable: true

    invalidActions: [
        "rename", "delete"
    ]

    onListIDChanged: {
        if (!updating)
            document.set("listID", listID)
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    customUploadFields: function() {
        listID = document.get("listID", "")
    }

    function loadTrello(json) {
        document.set("name", json.name)
        document.set("listID", json.id)

        reloadFields()
    }

    function refresh() {
        httpGET("/lists/" + listID + "/cards", [], loadTasks)
    }

    function loadTasks(response) {
        var json = JSON.parse(response)

        for (var i = 0; i < json.length; i++) {
            var task = getTask(json[i].id)
            if (task === undefined) {
                task = internal_newTask()
                task.loadTrello(json[i])
                task.refresh()
            } else {
                task.loadTrello(json[i])
            }
        }

        for (var k = 0; k < tasks.count; k++) {
            var found = false
            var task = tasks.get(k).modelData
            if (task.locked) return

            for (var j = 0; j < json.length; j++) {
                if (task.taskID === json[j].id) {
                    found = true
                    break
                }
            }

            if (!found)
                task.remove()
        }
    }

    function getTask(taskID) {
        for (var i = 0; i < tasks.count; i++) {
            if (tasks.get(i).modelData.taskID === taskID)
                return tasks.get(i).modelData
        }
    }

    function internal_newTask() {
        //print("Adding new task...")
        var task = createTask({
                          docId: nextDocId++
                      })
        internal_addTask(task)
        task.loadU1db()
        return task
    }

    function newTask(name) {
        //print("Adding new task...")
        var task = createTask({
                          docId: nextDocId++
                      })
        task.name = name
        task.locked = true
        addTask(task)
        return task
    }

    function addTask(task) {
        if (task.list !== list)
            task.list = list
        if (task.docId === "")
            task.docId = nextDocId++
        print("Adding task:", task.name)
        httpPOST("/lists/" + listID + "/cards", ["name=" + task.name], onNewTask, task)
        tasks.append({modelData: task})
        //print("TASKS", tasks.count)
    }

    function onNewTask(response, task) {
        print("Response:", response)
        var json = JSON.parse(response)
        task.taskID = json.id
        task.locked = false
    }

    function removeTask(task) {
        // For implementation by backend...
        httpDELETE("/cards/" + task.taskID)
        internal_removeTask(task)
    }

    taskComponent: Component {

        Task {

        }
    }
}
