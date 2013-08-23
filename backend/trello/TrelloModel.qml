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
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import "../../components"
import "Trello.js" as Trello
import "sha1.js" as SHA1
import "oauth.js" as OAUTH

Item {
    id: root

    property ListModel projects: ListModel {
        id: projects
    }

    property string name: "Trello Boards"
    property bool requiresInternet: true
    property bool loading: true
    property var database

    property var list: []

    property var upcomingTasks: {
        var tasks = []

        for (var i = 0; i < projects.count; i++) {
            tasks = tasks.concat(projects.get(i).modelData.upcomingTasks)
        }

        return tasks
    }

    function getBoard(boardID) {
        for (var i = 0; i < projects.count; i++) {
            if (projects.get(i).modelData.boardID === boardID)
                return projects.get(i).modelData
        }
    }

    function onError() {

    }

    function load() {
        Trello.token = getSetting("trello-token", "")

        if (Trello.token === "") {
//            https://trello.com/1/OAuthGetRequestToken
//            https://trello.com/1/OAuthAuthorizeToken
//            https://trello.com/1/OAuthGetAccessToken
//            var message = {
//                consumerKey: Trello.key,
//                consumerSecret: Trello.secret,
//                serviceProvider: {
//                    signatureMethod: "HMAC-SHA1",
//                    requestTokenURL: "https://trello.com/1/OAuthGetRequestToken",
//                    userAuthorizationURL: "https://trello.com/1/OAuthAuthorizeToken",
//                    accessTokenURL: "https://trello.com/1/OAuthGetAccessToken"/*,
//                    echoURL: "http://localhost/oauth-provider/echo"*/
//                }
//            }
            PopupUtils.open(trelloAuthentication, root)
        } else {
            var json = JSON.parse(tasksDocument.contents.tasks)

            if (runBefore) {
                print("LOADING...")
                for (var i = 0; i < json.length; i++) {
                    var project = newProject(json[i].name)
                    project.load(json[i])
                    project.refresh()
                }
            }

            authorized()
        }
    }

    function authorized() {
        Trello.call("/members/my/boards", [], onBoardsLoaded)
    }

    function onBoardsLoaded(response) {
        print("BOARDS:", response)
        var json = JSON.parse(response)
        for (var i = 0; i < json.length; i++) {
            print("Board:", json[i].name)
            var board = getBoard(json[i].id)
            if (board === undefined) {
                board = newProject(json[i].name)
                board.load(json[i])
                board.refresh()
            } else {
                board.load(json[i])
            }
        }
        loading = false
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

    Component {
        id: newProjectComponent

        Project {

        }
    }

    Component {
        id: trelloAuthentication

        TrelloAuthenticationDialog {
            onAccepted: authorized()
        }
    }

    U1db.Document {
        id: tasksDocument

        database: root.database
        docId: 'trello'
        create: true

        defaults: {
            tasks: ""
        }
    }
}
