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
//    headerColor: "#323A5D"
//    backgroundColor: "#6A6AA1"
//    footerColor: "#6899D7"

    //backgroundColor: "#FCFF95"
    //backgroundColor: "#FFFFBB"
    //footerColor: "#FFFCD7"

    property var pageStack: pageStack

    PageStack {
        id: pageStack

        Tabs {
            id: tabs

            Repeater {
                model: taskListsModel

                delegate: Tab {
                    title: page.title
                    page: TasksPage {
                        taskList: modelData
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
            taskLists: [
            {
                title: "Todo",
                tasks: [
                    {
                               title: "Blah"
                    }
                ]
            }
            ]
        }
    }

    ListModel {
        id: taskListsModel
    }

    function removeTaskList(taskList) {
        for (var i = 0; i < taskListsModel.count; i++) {
            if (taskListsModel.get(i).modelData === taskList) {
                taskListsModel.remove(i)
                break
            }
        }

        if (taskListsModel.count === 0) {
            newTaskListObject({
                                  title: i18n.tr("Tasks")
                              })
        }
    }

    function saveTasks() {
        print("Saving Task lists...")

        var lists = []

        for (var i = 0; i < taskListsModel.count; i++) {
            var list = taskListsModel.get(i).modelData
            print("Saving List:", list.title)
            lists.push(list.toJSON())
        }
        print("Lists:", lists)

        var tempContents = {}
        tempContents = tasksDatebase.contents
        tempContents.taskLists = JSON.stringify(lists)
        tasksDatebase.contents = tempContents
    }

    function loadTasks() {

        print("Loading lists...")
        var taskLists = JSON.parse(tasksDatebase.contents.taskLists)
        print(taskLists)

        for (var i = 0; i < taskLists.length; i++) {
            newTaskListObject(taskLists[i])
        }

        if (taskListsModel.count === 0) {
            newTaskListObject({
                                  title: i18n.tr("Tasks")
                              })
        }
    }

    function newTaskListObject(args) {
        print("Creating new list: ", args)
        var taskList = taskListComponent.createObject(root)
        taskList.loadJSON(args)

        if (taskList === null) {
            console.log("Unable to create task object!")
        }

        taskListsModel.append({modelData: taskList})
    }

    Component {
        id: taskListComponent

        TaskList {

        }
    }

    /*Component {
        id: taskComponent

        Task {

        }
    }*/

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
        loadTasks()
    }

    Component.onDestruction: {
        saveTasks()
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
        } else {
            return label
        }
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
