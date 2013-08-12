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
import U1db 1.0 as U1db

import "ui"
import "components"

MainView {
    id: root

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename 
    applicationName: "Tasks"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    anchorToKeyboard: true
    
    width: units.gu(50)
    height: units.gu(75)

    // Colors from Calculator app
    headerColor: "#323A5D"
    backgroundColor: "#6A6AA1"
    footerColor: "#6899D7"

    //backgroundColor: "#FCFF95"
    //backgroundColor: "#FFFFBB"
    //footerColor: "#FFFCD7"

    property var pageStack: pageStack

    PageStack {
        id: pageStack

        Tabs {
            id: tabs

            Tab {
                title: page.title
                page: TasksPage {
                    title: i18n.tr("All Tasks")
                    category: ""
                }
            }

            onVisibleChanged: tabBar.visible = visible

            Repeater {
                model: categories

                delegate: Tab {
                    title: page.title
                    page: TasksPage {
                        category: modelData
                    }
                }
            }

            visible: false
        }

        Component.onCompleted: pageStack.push(tabs)
    }

    /* TASK MANAGEMENT */

    U1db.Document {
        id: tasksDatebase

        database: storage
        docId: 'tasks'
        create: true

        defaults: {
            tasks: []
        }
    }

    ListModel {
        id: taskListModel
    }

    function addTask(args) {
        //print("ADDING TASK:", args)
        var task = taskComponent.createObject(root, args)

        if (task === null) {
            console.log("Unable to create task!")
        }

        addExistingTask(task)
    }

    function addExistingTask(task) {
        if (task.category !== "" && categories.indexOf(task.category) === -1) {
            console.log("WARNING: Task has new category:", task.category)
            addCategory(task.category)
        }

        taskListModel.append({"modelData": task})
    }

    function newTask(args) {
        return taskComponent.createObject(root, args)
    }

    function removeTask(task) {
        for (var i = 0; i < taskListModel.count; i++) {
            if (taskListModel.get(i).modelData === task) {
                taskListModel.remove(i)
                return
            }
        }
    }

    property var categories: []

    function addCategory(category) {
        var list = categories
        list.push(category)
        categories = list
        print(categories)

        tabs.selectedTabIndex = categories.length
    }

    function removeCategory(category) {
        //TODO: Add confirmation dialog

        for (var i = 0; i < taskListModel.count; i++) {
            var task = taskListModel.get(i).modelData
            if (task.category === category) {
                removeTask(task)
            }
        }

        if (categories.indexOf(category) != -1) {
            var list = categories
            list.splice(list.indexOf(category), 1)
            categories = list
            print(categories)
        }

        tabs.selectedTabIndex = 0
    }

    function renameCategory(category, newCategory) {
        var tab = tabs.selectedTab
        var list = categories
        list[categories.indexOf(category)] = newCategory
        categories = list

        for (var i = 0; i < taskListModel.count; i++) {
            var task = taskListModel.get(i).modelData
            if (task.category === category) {
                task.category = newCategory
            }
        }

        tabs.selectedTabIndex = tab
    }

    function loadCategories() {
        categories = JSON.parse(tasksDatebase.contents.categories)
    }

    function saveCategories() {
        var tempContents = {}
        tempContents = tasksDatebase.contents
        tempContents.categories = JSON.stringify(categories)
        tasksDatebase.contents = tempContents
    }

    function saveTasks() {
        //print("Saving Tasks...")

        var tasks = []

        for (var i = 0; i < taskListModel.count; i++) {
            var task = taskListModel.get(i).modelData
            //print("Saving task:", task.title)
            tasks.push(task.toJSON())
        }

        var tempContents = {}
        tempContents = tasksDatebase.contents
        tempContents.tasks = JSON.stringify(tasks)
        //print(tempContents.tasks)
        tasksDatebase.contents = tempContents
    }

    function filteredTasks(filter) {
        //print("Filtering...")
        var tasks = []

        //print("Filtered:", tasks)
        for (var i = 0; i < taskListModel.count; i++) {
            var task = taskListModel.get(i).modelData
            if (filter(task))
                tasks.push(task)
        }

        //print("Filtered:", tasks)

        return tasks
    }

    function countTasks(filter) {
        var count = 0

        for (var i = 0; i < taskListModel.count; i++) {
            var task = taskListModel.get(i).modelData
            if (filter(task))
                count++
        }

        //print("Count:", count)
        return count
    }

    function loadTasks() {
        print("Loading lists...")
        var tasks = JSON.parse(tasksDatebase.contents.tasks)
        print(tasks)

        for (var i = 0; i < tasks.length; i++) {
            addTask(tasks[i])
        }
    }

    Component {
        id: taskComponent

        Task {

        }
    }

    /* SETTINGS */

    property bool showCompletedTasks

    /* SETTINGS STORAGE */

    U1db.Database {
        id: storage
        path: "tasks-app"
    }

    U1db.Document {
        id: settings

        database: storage
        docId: 'settings'
        create: true

        defaults: {
            showCompletedTasks: false
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

        showCompletedTasks = getSetting("showCompletedTasks") === "true" ? true : false
    }

    Component.onCompleted: {
        reloadSettings()
        loadCategories()
        loadTasks()
        tabs.selectedTabIndex = 0
    }

    Component.onDestruction: {
        saveTasks()
        saveCategories()
    }

    /* LABEL MANAGEMENT */

    property var labels: ["green", "yellow", "red"]

    function labelName(label) {
        if (label === "green") {
            return "Low"
        } else if (label === "yellow") {
            return "Medium"
        } else if (label === "red") {
            return "High"
        } else {
            return "????"
        }
    }

    function labelColor(label) {
        if (label === "green") {
            return "#59B159"
        } else if (label === "yellow") {
            return "#FFFF41"
        } else if (label === "red") {
            return "#FF4141"
        } else {
            return label
        }
    }

    /* HELPER FUNCTIONS */

    function icon(name) {
        //return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
        return "../icons/" + name + ".png"
        //return "qrc:///icons/" + name + ".png"
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

    property var today: {
        var today = new Date()
        today.setHours(0)
        today.setMinutes(0)
        today.setSeconds(0)
        return today
    }
}
