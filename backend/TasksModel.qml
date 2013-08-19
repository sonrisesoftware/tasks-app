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
import U1db 1.0 as U1db

Item {
    id: root

    property ListModel projects: ListModel {
        id: projects
    }

    property string name: "Projects"
    property bool requiresInternet: false
    property var database

    property var list: []

    property var upcomingTasks: {
        var tasks = []

        for (var i = 0; i < projects.count; i++) {
            //print(projects.get(i).modelData.name, projects.get(i).modelData.upcomingTasks)
            tasks = tasks.concat(projects.get(i).modelData.upcomingTasks)
        }

        //print("Upcoming tasks:", tasks)

        return tasks
    }

    function load() {
        print("Loading...")
        if (!runBefore)
            return

        var json = JSON.parse(tasksDocument.contents.tasks)

        for (var i = 0; i < json.length; i++) {
            var project = newProject(json[i].name)
            project.load(json[i])
        }
    }

    function save() {
        var json = []

        for (var i = 0; i < projects.count; i++) {
            json.push(projects.get(i).modelData.save())
        }

        var tempDocument = tasksDocument
        var tempContents = {}
        tempContents.tasks = JSON.stringify(json)
        tempDocument.contents = tempContents
        tasksDocument = tempDocument
    }

    function newProject(name) {
        var project = newProjectComponent.createObject(root)
        project.backend = root

        if (project === null) {
            console.log("Unable to create project!")
        }

        project.name = name
        projects.append({"modelData": project})
        return project
    }

    function addProject(project) {
        projects.append(project)
    }

    function removeProject(project) {
        for (var i = 0; i < projects.count; i++) {
            if (projects.get(i).modelData === project)
                projects.remove(i)
        }
        project.destroy()
    }

    U1db.Document {
        id: tasksDocument

        database: root.database
        docId: 'tasks'
        create: true

        defaults: {
            tasks: ""
        }
    }

    Component {
        id: newProjectComponent

        Project {

        }
    }
}
