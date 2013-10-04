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
import U1db 1.0 as U1db
import ".."

GenericProject {
    id: project

    property var boardID
    editable: true
    enabled: true
    property bool locked: false

    invalidActions: {
        var actions = ["delete"]
        if (getListByName("") === "") actions.push("addTask")
        return actions
    }

    property var lists

    function getList(name) { return lists && lists[name] || ""}

    function getListByName(name) {
        if (lists === undefined) return ""

        var defaultKey = ""
        for (var key in lists) {
            if (defaultKey === "")
                defaultKey = key
            if (lists[key] === name) return key
        }

        if (name === "Doing")
            return getListByName("In Progress")

        return defaultKey
    }

    function hasList(name) {
        if (lists === undefined) return false

        for (var key in lists) {
            if (lists[key] === name) return true
        }

        if (name === "Doing")
            return hasList("In Progress")

        return false
    }

    property var trelloFields: {
        "name": "name",
        "archived": "closed",
        "description": "desc",
    }

    onBoardIDChanged: {
        if (!updating)
            document.set("boardID", boardID)
    }

    onListsChanged: {
        if (!updating)
            document.set("lists", lists)
    }

    property var deleteList: []

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    customUploadFields: function() {
        boardID = document.get("boardID", "")
        lists = document.get("lists", {})
    }

    function fieldChanged(name, value) {
        if (!updating) {
            if (trelloFields.hasOwnProperty(name)) {
                document.lock(name, value)
                httpPUT("/board/" + boardID + "/" + trelloFields[name], ["value=" + value], onFieldPosted, name)
            } else {
                document.set(name, value)
            }
        }
    }

    function onFieldPosted(response, name) {
        document.unlock(name)
    }

    function loadTrello(json) {
        document.set("name", json.name)
        document.set("boardID", json.id)
        document.set("archived", json.closed)
        document.set("description", json.desc)

        var labels = json.labelNames
        //print("Loading Trello labels:", JSON.stringify(labels))
        var colors = ["yellow", "red", "purple", "orange", "green", "blue"]
        var tags = {}
        for (var i = 0; i < colors.length; i++) {
            tags[colors[i]] = labels[colors[i]]
        }
        document.set("tags", tags)

        reloadFields()
    }

    function refresh() {
        httpGET("/boards/" + boardID + "/cards", [], loadTasks)
        httpGET("/boards/" + boardID + "/lists", [], loadLists)
    }

    function loadLists(response) {
        //print("Loading lists...")
        var json = JSON.parse(response)

        var list = {}
        for (var i = 0; i < json.length; i++) {
            list[json[i].id] = json[i].name
        }
        //print(JSON.stringify(list))

        lists = list
    }

    function loadTasks(response) {
        var json = JSON.parse(response)

        for (var i = 0; i < json.length; i++) {
            if (deleteList.indexOf(json[i].id) !== -1) continue

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
                internal_removeTask(task)
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
        if (task.project !== project)
            task.project = project
        if (task.docId === "")
            task.docId = nextDocId++
        print("Adding task:", task.name)
        httpPOST("/lists/" + getListByName("To Do") + "/cards", ["name=" + task.name], onNewTask, task)
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
        httpDELETE("/cards/" + task.taskID, [], onRemoveTask, task)
        deleteList.push(task.taskID)
        internal_removeTask(task)
    }

    function onRemoveTask(response, task) {
        deleteList.splice(deleteList.indexOf(task), 1)
    }

    taskComponent: Component {

        Task {

        }
    }
}
