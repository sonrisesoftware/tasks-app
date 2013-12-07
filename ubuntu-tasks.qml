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
    
    /*
     * Note: applicationName needs to match the "name" field of
     * the click manifest
     */
    applicationName: "com.ubuntu.developer.mdspencer.ubuntu-tasks"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    anchorToKeyboard: true
    
    width: units.gu(100)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    property bool extraWideAspect: width > units.gu(120)

    // Colors from Calculator app
    headerColor: "#323A5D"
    backgroundColor: "#6A6AA1"
    footerColor: "#6899D7"

    actions: [
        Action {
            id: settingsAction
            text: i18n.tr("Settings")
            iconSource: getIcon("settings")
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("ui/SettingsPage.qml"))
            }
        }

    ]

    property var pageStack: pageStack

    onWideAspectChanged: {
        if (wideAspect && tabs.selectedTabIndex == 3)
            tabs.selectedTabIndex = 1

        if (!wideAspect && tabs.selectedTabIndex == 1)
            tabs.selectedTabIndex = 3
    }

    PageStack {
        id: pageStack

        HomePage {
            id: homePage

            property int tabIndex: 0
            visible: false
        }

        HomePage {
            id: uncategorizedPage
            currentProject: uncategorizedProject

            property int tabIndex: 1
            visible: false
        }

        ProjectsPage {
            id: projectsPage

            property int tabIndex: 2
            visible: false
        }

        SearchPage {
            id: searchPage

            property int tabIndex: wideAspect ? 1 : 3
            visible: false
        }

        Tabs {
            id: tabs

            Repeater {
                model: root.wideAspect ? [homePage, searchPage] : [homePage, uncategorizedPage, projectsPage, searchPage]
                delegate: Tab {
                    title: page.title
                    page: modelData
                    Component.onCompleted: page.visible = true
                }
            }

            visible: false
        }

        Component.onCompleted: {
            clearPageStack()
        }
    }

    property bool topPageHidden: currentPage && currentPage.hasOwnProperty("hidden") ? currentPage.hidden : false

    onTopPageHiddenChanged: {
        if (topPageHidden && poppingEnabled) {
            print("Top page hidden, popping. Wide aspect:", wideAspect)
            pageStack.pop()
        }
    }

    property var poppingEnabled

    function clearPageStack() {
        while (pageStack.depth > 0)
            pageStack.pop()
        pageStack.push(tabs)
    }

    Notification {
        id: notification
    }

    property var showToolbar: wideAspect ? true : undefined

    states: [
        State {
            when: toolbar.tools.opened && toolbar.tools.locked

            PropertyChanges {
                target: pageStack
                anchors.bottomMargin: -root.toolbar.triggerSize
            }
        }
    ]

    property Page currentPage: pageStack.currentPage && pageStack.currentPage.hasOwnProperty("currentPage")
                               ? pageStack.currentPage.currentPage
                               : pageStack.currentPage

    property var viewing: currentPage && currentPage.hasOwnProperty("type") ? currentPage.type : "unknown"

    property var currentProject: currentPage && currentPage.hasOwnProperty("currentProject") ? currentPage.currentProject : null
    property var currentTask: currentPage && currentPage.hasOwnProperty("task") ? currentPage.task : null

//    onWideAspectChanged: {
//        var viewing = root.viewing
//        var currentProject = root.currentProject
//        var currentTask = root.currentTask

//        clearPageStack()
//        tabs.modelChanged()
//        homePage.currentProject = null

//        print("Switching to %1 in %2".arg(wideAspect ? "Wide Aspect" : "Phone").arg(viewing))

//        if (wideAspect) {
//            if (viewing === "projects" || viewing === "overview") {
//                tabs.selectedTabIndex = homePage.tabIndex
//            } else if (viewing === "project") {
//                tabs.selectedTabIndex = homePage.tabIndex
//                homePage.currentProject = currentProject
//            } else if (viewing === "task") {
//                tabs.selectedTabIndex = homePage.tabIndex
//                homePage.currentProject = currentTask.project
//                goToTask(currentTask)
//            } else if (viewing === "settings") {
//                tabs.selectedTabIndex = 2//settingsPage.tabIndex
//            } else if (viewing === "about") {
//                tabs.selectedTabIndex = 2//settingsPage.tabIndex
//                pageStack.push(Qt.resolvedUrl("ui/AboutPage.qml"))
//            } else if (viewing === "search") {
//                tabs.selectedTabIndex = 1//searchPage.tabIndex
//            } else if (viewing === "uncategorized") {
//                tabs.selectedTabIndex = homePage.tabIndex
//                homePage.currentProject = currentProject
//            }
//        } else {
//            if (viewing === "project") {
//                tabs.selectedTabIndex = projectsPage.tabIndex
//                goToProject(currentProject)
//            } else if (viewing === "overview") {
//                tabs.selectedTabIndex = homePage.tabIndex
//            } else if (viewing === "task") {
//                tabs.selectedTabIndex = projectsPage.tabIndex
//                goToTask(currentTask)
//            } else if (viewing === "settings") {
//                tabs.selectedTabIndex = 4//settingsPage.tabIndex
//            } else if (viewing === "about") {
//                tabs.selectedTabIndex = 4//settingsPage.tabIndex
//                pageStack.push(Qt.resolvedUrl("ui/AboutPage.qml"))
//            } else if (viewing === "search") {
//                tabs.selectedTabIndex = 3//searchPage.tabIndex
//            } else if (viewing === "uncategorized") {
//                tabs.selectedTabIndex = uncategorizedPage.tabIndex
//            }
//        }

//        tabs.modelChanged()
//    }

    /* NAVIGATION */

    function showStatistics(project) {
        poppingEnabled = false
        pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: project, pushedProject: true})
        pageStack.push(Qt.resolvedUrl("ui/StatisticsPage.qml"), {project: project})
        poppingEnabled = true
    }

    function goToProjects() {
        if (wideAspect) {
            tabs.selectedTabIndex = homePage.tabIndex
        } else {
            tabs.selectedTabIndex = projectsPage.tabIndex
        }
    }

    function goToProject(project) {
        if (wideAspect) {
            homePage.currentProject = project
            clearPageStack()
        } else {
            if (project === uncategorizedProject) {
                tabs.selectedTabIndex = uncategorizedPage.tabIndex
            } else {
                tabs.selectedTabIndex = projectsPage.tabIndex
                pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: project, pushedProject: true})
            }
        }
    }

    function goToTask(task) {
        poppingEnabled = false
        pageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {currentProject: task.project, pushedProject: true})
        pageStack.push(Qt.resolvedUrl("ui/TaskViewPage.qml"), {task: task})
        poppingEnabled = true
    }

    /* DEBUGGING */

    property var debugList: [
        //"database",
        //"document"
        //"task"
    ]

    function debug(name, text) {
        if (debugList.indexOf(name) !== -1)
            print(name.toUpperCase() + ":", text)
    }

    /* TASK MANAGEMENT */

    TrelloBackend.TrelloBackend {
        id: trello
    }

    LocalBackend.LocalBackend {
        id: localProjectsModel
    }

    property var backendModels: [
       localProjectsModel, trello
    ]

    property var enabledTasks: function(backend) { return backend.enabled }

    property var allTasks: concat(backendModels, "allTasks", enabledTasks)
    property var upcomingTasks: concat(backendModels, "upcomingTasks", enabledTasks)
    property var assignedTasks: concat(backendModels, "assignedTasks", enabledTasks)

    onUpcomingTasksChanged: {
        //print("Upcoming tasks:", length(upcomingTasks))
    }

    /* SETTINGS */

    property bool showCompletedTasks
    property bool showArchivedProjects
    property bool trelloIntegration
    property bool runBefore
    property string sortBy: "intPriority"

    /* CHECKING FOR INTERNET */

    /* UNDO STACK */

    UndoStack {
        id: undoStack
    }

    /* SETTINGS STORAGE */

    U1db.Database {
        id: storage
        path: "ubuntu-tasks.db"
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
        if (!dbChanged) return

        for (var i = 0; i < backendModels.length; i++) {
            var json = backendModels[i].save()
            debug("database", JSON.stringify(json))
            saveSetting("backend-" + backendModels[i].databaseName, JSON.stringify(json))
        }

        dbChanged = false
    }

    property bool dbChanged: false

    property bool activeState: Qt.application.active

    onActiveStateChanged: saveProjects()

    Timer {
        interval: 120000 // 2 minutes
        repeat: true
        running: true
        onTriggered: saveProjects()
    }

    property var uncategorizedProject: getItemByFilter(localProjectsModel.projects, function(project) { return project.special })

    Component.onCompleted: {
        notification.show("Undo", icon("back"), print, "Undoing test...")
        reloadSettings()

        for (var i = 0; i < backendModels.length; i++) {
            var text = getSetting("backend-" + backendModels[i].databaseName, "{}")
            print(text)
            var json = JSON.parse(text)
            backendModels[i].load(json)
        }

        if (!uncategorizedProject) {
            var project = localProjectsModel.newProject(i18n.tr("Uncategorized"))
            project.special = true
        }

        if (!runBefore) {
            saveSetting("runBefore", "true")
            firstRun()
        }
    }

    Component.onDestruction: saveProjects()

    /* INITIAL WELCOME PROJECT */

    function firstRun() {
    }

    /* PRIORITY MANAGEMENT */

    property var priorities: ["low", "medium", "high"]

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

    function labelColor(label) {
        if (label === "green") {
            return "#59B159"
        } else if (label === "yellow") {
            return "#FFFF41"
        } else if (label === "red") {
            return "#FF4141"
        } else if (label === "orange") {
            return "#FF7A0D"
        } else if (label === "purple") {
            return "#9933CC"
        } else if (label === "blue") {
            return "#3A69E0"//"#4D77CB"
        } else {
            return label
        }
    }

    function getItemByFilter(list, filter) {
        for (var i = 0; i < length(list); i++) {
            var item = getItem(list, i)
            if (filter(item))
                return item
        }

        return null
    }

    function filter(tasks, filter, name) {
        //print("Running filter:", name)
        var list = []

        for (var i = 0; i < length(tasks); i++) {
            var task = getItem(tasks, i)
            //print("Filtering:", task.name)
            if (filter(task))
                list.push(task)
        }

        //print("Filtered list:", list)

        return list
    }

    function filteredCount(model, func, name) {
        return filter(model, func, name).length
    }

    function filteredSum(list, prop, func, name) {
        var value = 0

        for (var i = 0; i < length(list); i++) {
            var item = getItem(list, i)
            value += filteredCount(item[prop], func, name)
        }

        return value
    }

    function sum(list, prop) {
        var value = 0

        for (var i = 0; i < length(list); i++) {
            var item = getItem(list, i)
            value += item[prop]
        }

        return value
    }

    function subList(list, prop) {
        var value = []

        //print("Concat:", prop, length(list))

        for (var i = 0; i < length(list); i++) {
            var item = getItem(list, i)
            value.push(item[prop])
        }

        //print("Concat:", prop, value, length(value))
        return value
    }

    function toList(model) {
        var list = []

        for (var i = 0; i < model.count; i++) {
            list.push(getItem(model, i))
        }

        return list
    }

    function sort(list, prop) {
        if (list.hasOwnProperty("count"))
            list = toList(list)
        //print("Sorting by", prop)
        list.sort(function(a, b) {
            return b.relevence - a.relevence
        });

        return list
    }

    function concat(list, prop, filter) {
        var value = []

        //print("Concat:", prop, length(list))

        for (var i = 0; i < length(list); i++) {
            var item = getItem(list, i)
            if (filter && !filter(item)) continue

            //print("Adding:", item[prop])
            if (item[prop].hasOwnProperty("length")) {
                value = value.concat(item[prop])
            } else {
                for (var j = 0; j < item[prop].count; j++) {
                    value.push(getItem(item[prop], j))
                }
            }
        }

        //print("Concat:", prop, value, length(value))
        return value
    }

    function icon(name) {
        return getIcon(name)
    }

    function getIcon(name) {
        var root = "icons/"
        var ext = ".png"

        //return "image://theme/" + name

        var name

        if (name.indexOf(".") === -1)
            name = root + name + ext
        else
            name = root + name

        return Qt.resolvedUrl(name)
    }

    function getItem(model, index) {
        var item = model.hasOwnProperty("get") ? model.get(index) : model[index]
        if (model.hasOwnProperty("get"))
            item = item.modelData

        return item
    }

    function length(model) {
        if (model === undefined || model === null)
            return 0
        else
            return model.hasOwnProperty("count") ? model.count : model.length
    }

    function newProject(caller, task) {
        if (filteredCount(backendModels, function(backend) { return backend.enabled }) > 1)
            PopupUtils.open(newProjectPopover, caller, {task: task})
        else
            PopupUtils.open(newProjectDialog, root, {
                                backend: backendModels[0],
                                task: task
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
        id: newProjectDialog

        InputDialog {
            property var backend
            property var task

            title: i18n.tr("New %1").arg(backend.newName)
            onAccepted: {
                var project = backend.newProject(value)
                goToProject(project)
                if (task !== undefined)
                    task.moveToProject(project)
            }
        }
    }

    Component {
        id: newProjectPopover

        Popover {
            id: newProjectPopoverItem

            property var task

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Repeater {
                    model: backendModels
                    delegate: ListItem.Standard {
                        visible: modelData.enabled // && modelData.editable

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
                            PopupUtils.open(newProjectDialog, root, {backend: modelData, task: task})
                        }

                        //showDivider: index < count - 1
                    }
                }
            }
        }
    }

//    Component {
//        id: renameProjectDialog

//        InputDialog {
//            property var project

//            id: renameProjectDialogItem
//            title: i18n.tr("Rename Project")
//            //text: i18n.tr("Are you sure you want to delete '%1'?").arg(project.name)
//            value: project.name

//            onAccepted: {
//                PopupUtils.close(renameProjectDialogItem)
//                project.name = value
//            }
//        }
//    }

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
                goToProject(null)
                project.remove()
            }
        }
    }

    Component {
        id: confirmDeleteTaskDialog

        ConfirmDialog {
            property var task

            id: confirmDeleteProjectDialogItem
            title: i18n.tr("Delete Task")
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(task.name)

            onAccepted: {
                PopupUtils.close(confirmDeleteProjectDialogItem)

                var project = task.project
                task.remove()
                clearPageStack()
                goToProject(project)
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
                    enabled: task.supportsAction("move")
                    onTriggered: {
                        PopupUtils.open(projectsPopover, caller, {
                                            task: task
                                        })
                    }
                }

                Action {
                    id: deleteAction
                    enabled: task.supportsAction("delete")

                    text: i18n.tr("Delete")
                    onTriggered: PopupUtils.open(confirmDeleteTaskDialog, root, {task: task})
                }
            }
        }
    }

    Component {
        id: projectActionsPopover

        ActionSelectionPopover {
            property var project
            property bool showArchived
            objectName: "projectActionsPopover"

            actions: ActionList {
                Action {
                    objectName: "edit"
                    text: i18n.tr("Edit")
                    enabled: (project.canEdit("name") || project.canEdit("description")) && !showArchived
                    onTriggered: {
                        PopupUtils.open(editProjectDialog, caller, {
                                            project: project
                                        })
                    }
                }

                Action {
                    objectName: "archive"
                    text: project.archived ? i18n.tr("Unarchive") : i18n.tr("Archive")
                    enabled: project.canEdit("archived")
                    onTriggered: {
                        project.archived = !project.archived
                        if (project.archived)
                            notification.show(i18n.tr("Archived %1").arg(project.name), icon("back"), function(project) {
                                project.archived = false
                            }, project)
                        if (project.archived)
                            goToProject(null)
                    }
                }

                Action {
                    objectName: "delete"
                    enabled: project.supportsAction("delete")
                    text: i18n.tr("Delete")
                    onTriggered: {
                        PopupUtils.open(confirmDeleteProjectDialog, root, {project: project})
                    }
                }
            }
        }
    }

    Component {
        id: editProjectDialog

        Dialog {
            id: projectDialogItem
            property var project

            title: i18n.tr("Edit Project")
            text: i18n.tr("Edit the name and description of %1").arg(project.name)

            TextField {
                id: nameField
                text: project.name
                enabled: project.canEdit("name")
                placeholderText: i18n.tr("Name")
            }

            TextArea {
                id: descriptionField
                text: project.description
                readOnly: !project.canEdit("description")
                placeholderText: i18n.tr("Description")
            }

            Button {
                text: i18n.tr("Ok")
                onTriggered: {
                    PopupUtils.close(projectDialogItem)
                    project.name = nameField.text
                    project.description = descriptionField.text
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onTriggered: PopupUtils.close(projectDialogItem)
                gradient: UbuntuColors.greyGradient
            }
        }
    }

    Component {
        id: projectsPopover

        ProjectsPopover {}
    }

    Component {
        id: tagsPopover

        TagsPopover {}
    }
}
