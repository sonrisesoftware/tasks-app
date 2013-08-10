/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * SuperTask Pro - A task management system for Ubuntu Touch               *
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
    id: root

    property string title

    property ListModel model: ListModel {
        id: model
    }

    function toJSON() {
        var json = []
        json.title = title

        var list = []

        for (var i = 0; i < model.count; i++) {
            var task = model.get(i).modelData
            list.push(task.toJSON())
        }

        json.tasks = list

        return toJSON()
    }

    function loadJSON(json) {
        print("Loading from JSON!")
        root.title = json.title
        print("TITLE:", root.title)
        var tasks = json.tasks

        for (var i = 0; i < tasks.length; i++) {
            newTaskObject(tasks[i])
        }
    }

    function loadTasks() {

    }

    function addTask(task) {
        tasksModel.append({"modelData": task})
    }

    function createTask() {
        return taskComponent.createObject()
    }

    function newTaskObject(args) {
        var task = taskComponent.createObject(root, args)

        if (task === null) {
            console.log("Unable to create task object!")
        }

        model.append({modelData: task})
    }

    function removeTask(task) {
        for (var i = 0; i < model.count; i++) {
            var item = model.get(i).modelData
            if (item === task) {
                model.remove(i)
                item.destroy()
                return
            }
        }
    }

    function filteredTasks(func) {
        var list = []
        for (var i = 0; i < model.count; i++) {
            if (func(model.get(i).modelData))
                list.push(model.get(i).modelData)
        }
        print("List count:", list.length)
        return list
    }

    function length(model) {
        if (model.hasOwnProperty("count")) {
            return model.count
        } else {
            return model.length
        }
    }
}
