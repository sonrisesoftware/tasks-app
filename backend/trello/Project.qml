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
import "Trello.js" as Trello
import ".."

GenericProject {
    id: root

    property var boardID
    editable: false
    enabled: true

    function load(json) {
        name = json.name
        boardID = json.id
        archived = json.closed
    }

    function refresh(json) {
        var tasks = json.tasks
        if (tasks === undefined)
            tasks = []

        for (var i = 0; i < tasks.length; i++) {
            var task = newTask(tasks[i])
            task.refresh()
        }

        backend.loading++
        Trello.call("/boards/" + boardID + "/cards", [], loadCards)
    }

    function loadCards(response) {
        var json = JSON.parse(response)

        for (var i = 0; i < json.length; i++) {
            var task = getCard(json[i].id)
            if (task === undefined) {
                task = newTask()
                task.load(json[i])
                task.refresh()
            } else {
                task.load(json[i])
            }
        }

        for (var k = 0; k < tasks.count; k++) {
            var found = false
            for (var j = 0; j < json.length; j++) {
                if (tasks.get(k).modelData.index === json[j].id) {
                    found = true
                    break
                }
            }

            if (!found)
                tasks.remove(k)
        }
        backend.loading--
    }

    function getCard(cardID) {
        for (var i = 0; i < tasks.count; i++) {
            if (tasks.get(i).modelData.index === cardID)
                return tasks.get(i).modelData
        }
    }

    function save() {
        var json = {}
        json.name = name
        json.id = boardID
        json.closed =archived
        json.tasks = []

        for (var i = 0; i < tasks.count; i++) {
            json.tasks.push(tasks.get(i).modelData.save())
        }

        return json
    }

    taskComponent: Component {
        id: taskComponent

        Task {

        }
    }
}
