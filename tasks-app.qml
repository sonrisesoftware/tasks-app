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
import QtSystemInfo 5.0

import "ui"
import "components"
import "backend"
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
    
    width: units.gu(100)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)

    // Colors from Calculator app
    headerColor: currentPage && currentPage.hasOwnProperty("headerColor") ? currentPage.headerColor : "#323A5D"
    backgroundColor: currentPage && currentPage.hasOwnProperty("backgroundColor") ? currentPage.backgroundColor : "#6A6AA1"
    footerColor: currentPage && currentPage.hasOwnProperty("footerColor") ? currentPage.footerColor : "#6899D7"

    //backgroundColor: "#FCFF95"
    //backgroundColor: "#FFFFBB"
    //footerColor: "#FFFCD7"

    property var pageStack: pageStack

    PageStack {
        id: pageStack

        Tabs {
            id: tabs

            property string type: "tabs"

            Tab {
                title: page.title
                page: HomePage {
                    id: homePage
                }
            }

            HideableTab {
                title: page.title
                page: ProjectsPage {
                    id: projectsPage

                }

                show: !wideAspect
            }

            visible: false
        }

//        Page {
//            id: testPage

//            UbuntuShape {
//                anchors.centerIn: parent
//                width: childrenRect.width
//                height: childrenRect.height
//                color: Qt.rgba(0.2,0.2,0.2,0.4)
//                //gradientColor: Qt.rgba(0.2,0.2,0.2,0.4)

//                Item {
//                    width: units.gu(20)
//                    height: units.gu(30)

//                    Spinner {
//                        anchors {
//                            left: parent.left
//                            right: parent.horizontalCenter
//                            top: parent.top
//                            bottom: parent.bottom
//                        }

//                        minValue: 1
//                        value: 3
//                        maxValue: 12
//                    }
//                    VerticalDivider {
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        anchors.margins: 1
//                    }

//                    Spinner {
//                        anchors {
//                            left: parent.horizontalCenter
//                            right: parent.right
//                            top: parent.top
//                            bottom: parent.bottom
//                        }

//                        minValue: 0
//                        maxValue: 59
//                    }
//                }
//            }
//        }

        Component.onCompleted: {
            pageStack.push(tabs)
            clearPageStack()
        }
    }

    property var showToolbar: wideAspect ? true : undefined

    property Page currentPage: pageStack.currentPage.hasOwnProperty("currentPage")
                               ? pageStack.currentPage.currentPage
                               : pageStack.currentPage

    property var currentProject: currentPage && currentPage.hasOwnProperty("currentProject") ? currentPage.currentProject : null
    property var currentTask: currentPage && currentPage.hasOwnProperty("task") ? currentPage.task : null

    property string viewing: currentPage && currentPage.hasOwnProperty("type")
                             ? currentPage.type
                             : currentTask !== null
                               ? "task"
                               : currentProject !== null
                                 ? "project"
                                 : "unknown"

    //onViewingChanged: print("Now viewing ", viewing)

    function clearPageStack() {
        while (pageStack.depth > 1)
            pageStack.pop()
        tabs.selectedTabIndex = 1
        tabs.selectedTabIndex = 0

        pageStack.push(Qt.resolvedUrl("ui/ProjectsPage.qml"))
        pageStack.pop()
        pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: null})
        pageStack.pop()
        pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: null})
        pageStack.pop()
    }

    onWideAspectChanged: {
        var currentProject = root.currentProject
        var viewing = root.viewing
        if (!wideAspect)
            homePage.currentProject = null

        if (viewing === "task") {
            goToTask(currentTask, "project")
        } else if (viewing === "project") {
            goToProject(currentProject)
        } else if (viewing === "add") {
            var task = currentTask
            goToProject(task.project)
            pageStack.push(addTaskPage, {task: task})
        } else if (viewing === "statistics") {
            var project = currentPage.project
            showStatistics(project)
        } else {
            if (!(viewing === "upcoming" || viewing === "projects")) {
                clearPageStack()
                console.log("Unknown type:", viewing)
            }

            clearPageStack()
            tabs.selectedTabIndex = 0
            homePage.currentProject = null
        }
    }

    function showStatistics(project) {
        goToProject(project)
        pageStack.push(statisticsPage, {project: project})
    }

    function goToTask(task, viewing) {
        if (viewing === undefined)
            viewing = root.viewing

        clearPageStack()

        if (wideAspect) {
            tabs.selectedTabIndex = 0
            if (viewing === "project")
                homePage.currentProject = task.project
            pageStack.push(Qt.resolvedUrl("ui/TaskViewPage.qml"), {task: task})
        } else {
            if (viewing === "project") {
                tabs.selectedTabIndex = 1
                pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: task.project})
            }

            pageStack.push(Qt.resolvedUrl("ui/TaskViewPage.qml"), {task: task})
        }
    }

    function goToProject(project) {
        clearPageStack()

        if (wideAspect) {
            tabs.selectedTabIndex = 0
            homePage.currentProject = project
        } else {
            tabs.selectedTabIndex = 1
            pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: project})
        }
    }

    /* TASK MANAGEMENT */

    TasksModel {
        id: localProjectsModel
        database: storage
    }

    property var backendModels: [
        localProjectsModel
    ]

    property var upcomingTasks: localProjectsModel.upcomingTasks

    /* SETTINGS */

    property bool showCompletedTasks
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
            runBefore: "false"
            width: units.gu(100)
            height: units.gu(75)
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
            //print(name, "=>", value)
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
        runBefore = getSetting("runBefore") === "true" ? true : false
    }

    function saveProjects() {
        for (var i = 0; i < backendModels.length; i++) {
            backendModels[i].save()
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
        //width = getSetting("windowWidth")
        //height = getSetting("windowHeight")

        for (var i = 0; i < backendModels.length; i++) {
            backendModels[i].load()
        }

        //print("Run before: ", runBefore)
        if (!runBefore) {
            saveSetting("runBefore", "true")
            firstRun()
        }
    }

    Component.onDestruction: {
        //saveSetting("windowWidth", width)
        //saveSetting("windowHeight", height)
        saveProjects()
    }

    /* INITIAL WELCOME PROJECT */

    function firstRun() {
        var project = localProjectsModel.newProject("Getting Started")
        project.newTask({name: "Welcome to Ubuntu Tasks"})
        project.newTask({name: "To view a task's description, tap it", description: "Here is the description for the task"})
        project.newTask({name: "To complete a task, tap the checkbox on at the right"})
        project.newTask({name: "When completed, tasks disappear from view"})
        project.newTask({name: "To show completed tasks, click the Options toolbar button"})
        project.newTask({name: "This is a completed task", completed: true, completedDate: new Date()})
        project.newTask({name: "To set a due date, priority, or other options, tap it", description: "Look below at the options you can set"})
        project.newTask({name: "To create a new task or project, look in the toolbar"})
        project.newTask({name: "To create a new task, you can also type in the quick add task field"})
        project.newTask({name: "When you're done learning, you can delete this project"})
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

    function length(model) {
        return model.hasOwnProperty("count") ? model.count : model.length
    }

    function filteredTasks(tasks, filter, name) {
        //print("Running filter:", name)
        var list = []

        for (var i = 0; i < length(tasks); i++) {
            var task = tasks.hasOwnProperty("get") ? tasks.get(i) : tasks[i]
            if (task.hasOwnProperty("modelData"))
                task = task.modelData
            //print("Filtering:", task.name)
            if (filter(task))
                list.push(task)
        }

        //print("Count:", list.length)
        return list
    }

    function countTasks(tasks, filter) {
        //print("Counting tasks...")
        var count = 0

        for (var i = 0; i < tasks.count; i++) {
            if (filter(tasks.get(i).modelData))
                count++
        }

        return count
    }

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
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(task.name)

            onAccepted: {
                PopupUtils.close(confirmDeleteTaskDialogItem)
                goToProject(task.project)
                task.remove()
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
                project.remove()
            }
        }
    }

    Component {
        id: newProjectDialog

        InputDialog {
            title: i18n.tr("New Project")
            placeholderText: i18n.tr("Project name")
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
        id: projectsPopover

        ProjectsPopover {

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
                        PopupUtils.open(projectsPopover, caller, {
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
