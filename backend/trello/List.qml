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

    onListIDChanged: {
        if (!updating)
            document.set("listID", listID)
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    function reloadFields() {
        //print("Reloading list", name)
        updating = true

        name = document.get("name", "")
        listID = document.get("listID", "")

        updating = false
        //print("Done.")
    }

    function loadTrello(json) {
        name = json.name
        listID = json.id
    }

    function refresh() {
        get("/lists/" + listID + "/cards", [], loadTasks)
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

    taskComponent: Component {

        Task {

        }
    }
}
