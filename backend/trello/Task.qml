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
import ".."
import "Trello.js" as Trello

GenericTask {
    id: task

    editable: false

    property string checklistID: ""

    function loadTrello(json) {
        name = json.name
        completed = json.closed
        index = json.id
        if (json.idChecklists.length > 0)
            checklistID = json.idChecklists[0] // FIXME: support more than one checklist!
        else
            checklistID = ""
        description = json.badges.description ? json.desc : ""
    }

    function refresh() {

    }

    onChecklistIDChanged: {
        if (checklistID !== "") {
            loading++
            Trello.call("/checklists/" + checklistID, [], loadChecklist)
        }
    }

    function loadChecklist(response) {
        var json = JSON.parse(response)
        print("CHECKLIST>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")

        var items = json.checkItems
        checklist.clear()
        for (var i = 0; i < items.length; i++) {
            checklist.add(items[i].name, items[i].state === "complete")
        }

        loading--
    }

    function remove() {
        project.removeTask(task)
    }

    function moveTo(project) {
        task.project.removeTask(task)
        task.project = project
        project.addTask(task)
    }
}
