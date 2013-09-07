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
import U1db 1.0 as U1db

Item {
    id: root

    /* Properties that define how the backend works */

    property string name
    property string newName
    property string databaseName                // The database filename
    enabled: true                               // Is this backend enabled?
    property bool editable: true                // Can projects/lists/tasks be edited/created/deleted?
    property bool requiresInternet: false       // Requires the internet to sync?
    property bool supportsStatistics: true      // Supports showing the statistics page?
    property bool supportsLists: true           // Supports multiple tasks lists?
    property var projectComponent
    property var allTasks: concat(projects, "allTasks")
    property var upcomingTasks: concat(projects, "upcomingTasks", function(project) { return !project.archived })
    property int loading: 0
    property int totalLoading: 0
    property var nonEditableFields: []
    property var invalidActions: []

    function supportsAction(name) {
        return editable && invalidActions.indexOf(name) === -1
    }

    function canEdit(name) {
        return editable && nonEditableFields.indexOf(name) === -1
    }

    property int archivedProjectsCount: count(projects, function(project) { return project.archived && !project.special })
    property int openProjectsCount: count(projects, function(project) { return !project.archived && !project.special })

    property int nextDocId: 0

    /* The actual projects model */

    property var projects: ListModel {
        id: projects
    }

    /* Loading/Saving of tasks */

    function load(json) {
        // By default, loads projects from U1db
        loadU1db(json)
    }

    function save() {
        // By default, saves projects in U1db
        return saveU1db()
    }

    /* Creation of new projects */

    // This is the front-end to creating new projects
    function newProject(name) {
        print("Generic new project...")
        var project = createProject({
                          docId: nextDocId++
                      })
        project.name = name
        internal_addProject(project)
        project.loadU1db()
        return project
    }

    // For loading a project from U1db
    function loadProjectU1db(docId) {
        var project = createProject({
                                        docId: docId
                                    })
        internal_addProject(project)
        project.loadU1db()
        return project
    }

    // Creates a new project object
    function createProject(args) {
        if (args === undefined)
            args = {}
        args.backend = root

        var project = projectComponent.createObject(root, args)

        if (project === null) {
            console.log("Unable to create:", newName)
        }

        return project
    }

    // This adds a project to the model
    function internal_addProject(project) {
        projects.append({modelData: project})
    }

    /* Deletion of projects */

    // This is the front-end to removing projects
    function removeProject(project) {
        // For implementation by backend...
        internal_removeProject(project)
    }

    // This removes a project from the model
    function internal_removeProject(project) {
        database.remove(project.docId)
        print("Removing project...")
        for (var i = 0; i < projects.count; i++) {
            if (projects.get(i).modelData === project)
                projects.remove(i)
        }
    }


    /* Local storage of the model in U1db */

    property var database: Document {
        id: database
        docId: databaseName
        name: "Plugin"
    }

    function loadU1db(json) {
        //print("Loading U1db from", JSON.stringify(json))
        database.load(json)

        nextDocId = database.get("nextDocId", 0)
        var list = database.listDocs()

        for (var i = 0; i < list.length; i++) {
            loadProjectU1db(list[i])
        }
    }

    function saveU1db() {
        database.set("nextDocId", nextDocId)
        return database.save()
    }
}
