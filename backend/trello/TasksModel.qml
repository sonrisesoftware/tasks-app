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

    property string name: "Trello Boards"
    property bool requiresInternet: true

    property var list: []

    property var upcomingTasks: {
        var tasks = []

        for (var i = 0; i < projects.count; i++) {
            tasks = tasks.concat(projects.get(i).modelData.upcomingTasks)
        }

        return tasks
    }

    function onError() {

    }

    function load() {
        Trello.authorize({name: "Ubuntu Tasks", error: onError})
    }

    function save() {

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

    Component {
        id: newProjectComponent

        Project {

        }
    }
}
