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
    
    width: units.gu(100)
    height: units.gu(75)

    Page {
        title: "Test"
    }

    /* TASK MANAGEMENT */

    LocalBackend.LocalBackend {
        id: localProjectsModel
    }

    property var backendModels: [
       localProjectsModel
    ]

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
            saveSetting("backend-" + backendModels[i].databaseName, backendModels[i].save())
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

        //var project = localProjectsModel.newProject("Test")

        var project = localProjectsModel.projects.get(0).modelData
        project.description = "NEW DESCRIPTION"
        project.load({
                         name: "OLD",
                         description: "OLD DESCRIPTION"
                     })
        print("Name:", project.name)
        print("Description:", project.description)

        print("Documents:", localProjectsModel.projects.count)
    }

    Component.onDestruction: {
        //saveSetting("windowWidth", width)
        //saveSetting("windowHeight", height)
        saveProjects()
    }

    /* INITIAL WELCOME PROJECT */

    function firstRun() {
    }
}
