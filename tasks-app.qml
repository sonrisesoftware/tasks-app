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
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import U1db 1.0 as U1db
import QtSystemInfo 5.0
import Ubuntu.OnlineAccounts 0.1

import "ui"
import "components"
import "backend"
import "backend/local" as LocalBackend
import "backend/trello" as TrelloBackend
import "ubuntu-ui-extras"

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

    property bool wideAspect: false//width > units.gu(80)

    // Colors from Calculator app
    headerColor: "#323A5D"
    backgroundColor: "#6A6AA1"
    footerColor: "#6899D7"

    property var pageStack: pageStack

    PageStack {
        id: pageStack

        Tabs {
            id: tabs

            //FIXME: Needs to be disabled for Autopilot tests
            HideableTab {
                title: page.title
                page: UpcomingPage {
                    id: upcomingPage
                }
                show: length(upcomingTasks) > 0
            }

            Tab {
                objectName: "projectsTab"

                title: page.title
                page: ProjectsPage {
                    id: projectsPage
                }
            }

            Tab {
                title: page.title
                page: SettingsPage {
                    id: settingsPage
                }
            }

            visible: false
        }

        Component.onCompleted: pageStack.push(tabs)
    }

    /* NAVIGATION */

    function goToProject(project) {
        if (project.supportsLists) {
            pageStack.push(Qt.resolvedUrl("ui/ListsPage.qml"), {currentProject: project})
        } else {
            pageStack.push(Qt.resolvedUrl("ui/TasksPage.qml"), {currentList: project.lists.get(0).modelData})
        }
    }

    function goToList(list) {
        pageStack.push(Qt.resolvedUrl("ui/TasksPage.qml"), {currentList: list})
    }

    /* TASK MANAGEMENT */

    LocalBackend.LocalBackend {
        id: localProjectsModel
    }

    property var backendModels: [
       localProjectsModel
    ]

    property var upcomingTasks: concat(backendModels, "upcomingTasks")

    onUpcomingTasksChanged: print("UPCOMING TASKS:", upcomingTasks)

    /* SETTINGS */

    property bool showCompletedTasks
    property bool showArchivedProjects
    property bool trelloIntegration
    property bool runBefore

    /* CHECKING FOR INTERNET */

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
            showCompletedTasks: "false"
            showArchivedProjects: "false"
            trelloIntegration: "false"
            runBefore: "false"
            width: units.gu(100)
            height: units.gu(75)
        }
    }

    U1db.Document {
        id: backendStorage

        database: storage
        docId: 'storage'
        create: true
    }

    function showSettings() {
        PopupUtils.open(settingsSheet)
    }

    function getSetting(name, def) {
        var tempContents = {};
        tempContents = settings.contents
        var value = tempContents.hasOwnProperty(name)
                ? tempContents[name]
                : settings.defaults.hasOwnProperty(name)
                  ? settings.defaults[name]
                  : def
        //print(name, JSON.stringify(def), JSON.stringify(value))
        return value
    }

    function saveSetting(name, value) {
        if (getSetting(name) !== value) {
            //print(name, "=>", value)
            var tempContents = {}
            tempContents = settings.contents
            tempContents[name] = value
            settings.contents = tempContents

            reloadSettings()
        }
    }

    function reloadSettings() {
        showCompletedTasks = getSetting("showCompletedTasks") === "true"
        showArchivedProjects = getSetting("showArchivedProjects") === "true"
        trelloIntegration = getSetting("trelloIntegration") === "true"
        runBefore = getSetting("runBefore") === "true" ? true : false
    }

    function saveProjects() {
        for (var i = 0; i < backendModels.length; i++) {
            var json = backendModels[i].save()
            print(JSON.stringify(json))
            saveSetting("backend-" + backendModels[i].databaseName, json)
        }
    }

    Timer {
        interval: 60000 // 60 seconds
        repeat: true
        running: true
        onTriggered: saveProjects()
    }

    Component.onCompleted: {
        reloadSettings()

        for (var i = 0; i < backendModels.length; i++) {
            var json = getSetting("backend-" + backendModels[i].databaseName, {})
            backendModels[i].load(json)
        }

        if (!runBefore) {
            saveSetting("runBefore", "true")
            firstRun()
        }
    }

    Component.onDestruction: {
        saveProjects()
    }

    /* INITIAL WELCOME PROJECT */

    function firstRun() {
    }

    /* PRIORITY MANAGEMENT */

    function priorityName(priority) {
        if (priority === "low") {
            return i18n.tr("Low")
        } else if (priority === "medium") {
            return i18n.tr("Medium")
        } else if (priority === "high") {
            return i18n.tr("High")
        } else {
            return i18n.tr("Unknown")
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

    /* UTILITY FUNCTIONS */

    function filter(tasks, filter, name) {
        //print("Running filter:", name)
        var list = []

        for (var i = 0; i < length(tasks); i++) {
            var task = get(tasks, i)
            //print("Filtering:", task.name)
            if (filter(task))
                list.push(task)
        }

        print("Count:", list.length)
        return list
    }

    function count(model, func, name) {
        return filter(model, func, name).length
    }

    function filteredSum(list, prop, func, name) {
        var value = 0

        for (var i = 0; i < length(list); i++) {
            var item = get(list, i)
            value += count(item[prop], func, name)
        }

        return value
    }

    function sum(list, prop) {
        var value = 0

        for (var i = 0; i < length(list); i++) {
            var item = get(list, i)
            value += item[prop]
        }

        return value
    }

    function concat(list, prop) {
        var value = []

        //print("Concat:", prop, value, length(value))

        for (var i = 0; i < length(list); i++) {
            var item = get(list, i)
            value.concat(item[prop])
        }

        //print("Concat:", prop, value, length(value))
        return value
    }

    function icon(name) {
        return "../icons/" + name + ".png"
    }

    function get(model, index) {
        var item = model.hasOwnProperty("get") ? model.get(index) : model[index]
        if (model.hasOwnProperty("get"))
            item = item.modelData

        return item
    }

    function length(model) {
        return model.hasOwnProperty("count") ? model.count : model.length
    }

    function newProject() {
        if (backendModels.length > 1)
            PopupUtils.open(newProjectPopover, newProjectButton)
        else
            PopupUtils.open(newProjectDialog, root, {
                                backend: backendModels[0]
                            })
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
        id: newProjectDialog

        InputDialog {
            property var backend

            title: i18n.tr("New %1").arg(backend.newName)
            onAccepted: backend.newProject(value)
        }
    }

    Component {
        id: newProjectPopover

        Popover {
            id: newProjectPopoverItem
            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Repeater {
                    model: backendModels
                    delegate: ListItem.Standard {
                        visible: modelData.editable

                        //FIXME: Hack because of Suru theme!
                        Label {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                margins: units.gu(2)
                            }

                            text: modelData.newName
                            fontSize: "medium"
                            color: Theme.palette.normal.overlayText
                        }

                        onClicked: {
                            PopupUtils.close(newProjectPopoverItem)
                            PopupUtils.open(newProjectDialog, root, {backend: modelData})
                        }

                        //showDivider: index < count - 1
                    }
                }
            }
        }
    }

    Component {
        id: projectActionsPopover

        ActionSelectionPopover {
            property var project
            objectName: "projectActionsPopover"

            actions: ActionList {
                Action {
                    objectName: "rename"
                    text: i18n.tr("Rename")
                    enabled: project.editable
                    onTriggered: {
                        PopupUtils.open(renameProjectDialog, caller, {
                                            project: project
                                        })
                    }
                }

                Action {
                    objectName: "archive"
                    text: project.archived ? i18n.tr("Unarchive") : i18n.tr("Archive")
                    enabled: project.editable
                    onTriggered: {
                        project.archived = !project.archived
                    }
                }

                Action {
                    objectName: "delete"
                    enabled: project.editable
                    text: i18n.tr("Delete")
                    onTriggered: {
                        PopupUtils.open(confirmDeleteProjectDialog, root, {project: project})
                    }
                }
            }
        }
    }

    Component {
        id: renameProjectDialog

        InputDialog {
            property var project

            id: renameProjectDialogItem
            title: i18n.tr("Rename Project")
            //text: i18n.tr("Are you sure you want to delete '%1'?").arg(project.name)
            value: project.name

            onAccepted: {
                PopupUtils.close(renameProjectDialogItem)
                project.name = value
            }
        }
    }

    Component {
        id: confirmDeleteProjectDialog

        ConfirmDialog {
            property var project

            id: confirmDeleteProjectDialogItem
            title: i18n.tr("Delete Project")
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(project.name)

            onAccepted: {
                PopupUtils.close(confirmDeleteProjectDialogItem)
                //clearPageStack()
                while (pageStack.depth > 1)
                    pageStack.clear()
                project.remove()
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
                    enabled: task.editable
                    onTriggered: {
                        PopupUtils.open(projectsPopover, caller, {
                                            task: task
                                        })
                    }
                }

                Action {
                    id: deleteAction
                    enabled: task.editable

                    text: i18n.tr("Delete")
                    onTriggered: task.remove()
                }
            }
        }
    }
}
