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

Item {
    id: root

    property ListModel tasks: ListModel {
        id: tasks

        onDataChanged: {
            upcomingTasks.clear()
            for (var i = 0; i < tasks.count; i++) {
                if (tasks.get(i).modelData.upcoming)
                    upcomingTasks.append(tasks.get(i))
            }
        }
    }

    property ListModel upcomingTasks: ListModel {
        id: upcomingTasks
    }

    property var backend

    property string name
    property alias count: tasks.count

    function load(json) {
        name = json.name
        var tasks = json.tasks
        for (var i = 0; i < tasks.length; i++) {
            newTask(tasks[i])
        }
    }

    function save() {
        var json = {}
        json.name = name
        json.tasks = []

        for (var i = 0; i < tasks.count; i++) {
            json.tasks.push(tasks.get(i).modelData.save())
        }

        return json
    }

    function newTask(args) {
        var task = createTask(args)

        addTask(task)
        return task
    }

    function createTask(args) {
        var task = taskComponent.createObject(tasks, args)

        if (task === null) {
            console.log("Unable to create task!")
        }

        task.project = root
        return task
    }

    function addTask(task) {
        tasks.append({"modelData": task})
    }

    function removeTask(task) {
        for (var i = 0; i < tasks.count; i++) {
            if (tasks.get(i) === task) {
                tasks.remove(i)
            }
        }
    }

    function remove() {
        backend.removeProject(root)
    }

    Component {
        id: taskComponent

        Task {

        }
    }
}
