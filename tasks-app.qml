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
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db

import "ui"
import "components"
import "backend"

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
    
    width: units.gu(100)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)

    // Colors from Calculator app
    headerColor: pageStack.currentPage.hasOwnProperty("headerColor") ? pageStack.currentPage.headerColor : "#323A5D"
    backgroundColor: pageStack.currentPage.hasOwnProperty("backgroundColor") ? pageStack.currentPage.backgroundColor : "#6A6AA1"
    footerColor: pageStack.currentPage.hasOwnProperty("footerColor") ? pageStack.currentPage.footerColor : "#6899D7"

    //backgroundColor: "#FCFF95"
    //backgroundColor: "#FFFFBB"
    //footerColor: "#FFFCD7"

    property var pageStack: pageStack

    PageStack {
        id: pageStack

        HomePage {
            id: homePage
            visible: false
        }

        Component.onCompleted: {
            pageStack.push(homePage)
        }
    }

    function goToTask(task) {
        pageStack.push(Qt.resolvedUrl("ui/TaskViewPage.qml"), {task: task})
    }

    /* TASK MANAGEMENT */

    TasksModel {
        id: localProjectsModel
        database: storage
    }

    property var backendModels: [
        localProjectsModel
    ]

    /* SETTINGS */

    property bool showCompletedTasks

    /* SETTINGS STORAGE */

    U1db.Database {
        id: storage
        path: "tasks-app.db"
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
        projectsModel.load()
    }

    Component.onDestruction: {
        projectsModel.save()
    }

    /* PRIORITY MANAGEMENT */

    property var priorities: ["low", "medium", "high"]

    function priorityName(priority) {
        if (priority === "low") {
            return "Low"
        } else if (priority === "medium") {
            return "Medium"
        } else if (priority === "high") {
            return "High"
        } else {
            return "????"
        }
    }

    function priorityColor(priority) {
        if (priority === "low") {
            return "#59B159"
        } else if (priority === "medium") {
            return "#FFFF41"
        } else if (priority === "high") {
            return "#FF4141"
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

    function dateIsBefore(date1, date2) {
        var ans = date1.getFullYear() < date2.getFullYear() ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() < date2.getMonth()) ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() === date2.getMonth()
                        && date1.getDate() < date2.getDate())
        return ans
    }

    function dateIsBeforeOrSame(date1, date2) {
        var ans = date1.getFullYear() < date2.getFullYear() ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() < date2.getMonth()) ||
                (date1.getFullYear() === date2.getFullYear() && date1.getMonth() === date2.getMonth()
                        && date1.getDate() <= date2.getDate())
        return ans
    }

    /* COMPONENTS */

    Component {
        id: optionsPopover

        OptionsPopover {

        }
    }

    Component {
        id: addTaskPage

        AddTaskPage {

        }
    }

    Component {
        id: statisticsPage

        StatisticsPage {

        }
    }

    Component {
        id: confirmDeleteTaskDialog

        ConfirmDialog {
            property var task

            id: confirmDeleteTaskDialogItem
            title: i18n.tr("Delete Task")
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(task.title)

            onAccepted: {
                var task = root.task
                PopupUtils.close(confirmDeleteTaskDialogItem)
                goToCategory(task.category)
                task.remove()
            }
        }
    }

    Component {
        id: confirmDeleteCategoryDialog

        ConfirmDialog {
            property string category

            id: confirmDeleteCategoryDialogItem
            title: i18n.tr("Delete Category")
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(category)

            onAccepted: {
                PopupUtils.close(confirmDeleteCategoryDialogItem)
                clearPageStack()
                removeCategory(category)
            }
        }
    }

    Component {
        id: newProjectDialog

        InputDialog {
            title: i18n.tr("New Project")
            onAccepted: localProjectsModel.newProject(value)
        }
    }

    Component {
        id: projectActionsPopover

        ActionSelectionPopover {
            property var project

            actions: ActionList {
                Action {
                    text: i18n.tr("Rename")
                    onTriggered: {
                        PopupUtils.open(renameProjectDialog, caller, {
                                            project: project
                                        })
                    }
                }

                Action {
                    text: i18n.tr("Delete")
                    onTriggered: {
                        PopupUtils.open(confirmDeleteProjectDialog, root, {project: project})
                    }
                }
            }
        }
    }

    Component {
        id: taskActionsPopover

        ActionSelectionPopover {
            property var task

            actions: ActionList {
                Action {
                    id: moveAction

                    text: i18n.tr("Move")
                    onTriggered: {
                        PopupUtils.open(Qt.resolvedUrl("../components/CategoriesPopover.qml"), caller, {
                                            task: task
                                        })
                    }
                }

                Action {
                    id: deleteAction

                    text: i18n.tr("Delete")
                    onTriggered: task.remove()
                }
            }
        }
    }
}
