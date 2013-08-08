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
import Ubuntu.Components 0.1
import U1db 1.0 as U1db

import "ui"
import "components"

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename 
    applicationName: "Tasks"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: true
    
    width: units.gu(50)
    height: units.gu(75)

    PageStack {
        id: pageStack

        TasksPage {
            id: tasksPage
            objectName: "tasksPage"

            visible: false
        }

        Component.onCompleted: pageStack.push(tasksPage)
    }


    /* TASK MANAGEMENT */

    U1db.Document {
        id: tasksDatebase

        database: storage
        docId: 'tasks'
        create: true

        defaults: {
            tasks: [{}]
        }
    }

    function saveTasks() {
        print("Saving TASKS...")

        var tasks = []

        for (var i = 0; i < tasksModel.count; i++) {
            var task = tasksModel.get(i).modelData
            tasks.push(task.toJSON())
        }

        var tempContents = {}
        tempContents = tasksDatebase.contents
        tempContents.tasks = JSON.stringify(tasks)
        tasksDatebase.contents = tempContents
    }

    function loadTasks() {
        var tasks = JSON.parse(tasksDatebase.contents.tasks)

        for (var i = 0; i < tasks.length; i++) {
            newTaskObject(tasks[i])
        }
    }

    function addTask(task) {
        tasksModel.append({"modelData": task})
    }

    function createTask() {
        return taskComponent.createObject()
    }

    function newTaskObject(args) {
        var task = taskComponent.createObject(tasksModel, args)

        if (task === null) {
            console.log("Unable to create task object!")
        }

        tasksModel.append({"modelData": task})
    }

    function removeTask(task) {
        for (var i = 0; i < tasksModel.count; i++) {
            var item = tasksModel.get(i).modelData
            if (item === task) {
                tasksModel.remove(i)
                item.destroy()
                return
            }
        }
    }

    Component {
        id: taskComponent

        Task {

        }
    }

    ListModel {
        id: tasksModel
    }

    function filteredTasks(func) {
        var list = []
        for (var i = 0; i < tasksModel.length; i++) {
            if (func(tasksModel[i])) list.push(tasksModel[i])
        }
        print("List count:", list.length)
        return list
    }

    /* SETTINGS STORAGE */

    U1db.Database {
        id: storage
        path: "supertaskpro"
    }

    U1db.Document {
        id: settings

        database: storage
        docId: 'settings'
        create: true

        defaults: {

        }
    }

    function showSettings() {
        PopupUtils.open(settingsSheet)
    }

    function getSetting(name) {
        var tempContents = {};
        tempContents = settings.contents
        return tempContents.hasOwnProperty(name) ? tempContents[name] : settings.defaults[name]
    }

    function saveSetting(name, value) {
        if (getSetting(name) !== value) {
            print(name, "=>", value)
            var tempContents = {}
            tempContents = settings.contents
            tempContents[name] = value
            settings.contents = tempContents

            reloadSettings()
        }
    }

    function reloadSettings() {
        //showVerse = getSetting("showVerse") === "true" ? true : false
        //print("showVerse <=", showVerse)
    }

    Component.onCompleted: {
        reloadSettings()
        loadTasks()
    }

    Component.onDestruction: {
        saveTasks()
    }

    /* HELPER FUNCTIONS */

    function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }

    function formattedDate(date) {
        if (isToday(date)) {
            return i18n.tr("Today")
        } else {
            return Qt.formatDate(date)
        }
    }

    function isToday(date) {
        var today = new Date()

        return date.getFullYear() === today.getFullYear() &&
                date.getMonth() === today.getMonth() &&
                date.getDate() === today.getDate()
    }
}
