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

GenericTask {
    id: task

    editable: true
    property string checklistID: ""
    property string taskID
    property bool locked: false

    nonEditableFields: [
        "repeat", "tags", "checklist", "priority"
    ]

    invalidActions: ["move"]

    property var trelloFields: {
        "name": "name",
        "description": "desc",
        "completed": "closed",
        "dueDate": "due"
    }

    onTaskIDChanged: {
        if (!updating)
            document.set("taskID", taskID)
    }

    customUploadFields: function() {
        taskID = document.get("taskID", "")
    }

    function fieldChanged(name, value) {
        if (!updating) {
            if (trelloFields.hasOwnProperty(name)) {
                document.lock(name, value)
                if (name === "dueDate" && Qt.formatDate(value) === "") {
                    httpPUT("/cards/" + taskID + "/" + trelloFields[name], ["value=" + null], onFieldPosted, name)
                } else {
                    httpPUT("/cards/" + taskID + "/" + trelloFields[name], ["value=" + value], onFieldPosted, name)
                }
            } else {
                document.set(name, value)
            }
        }
    }

    function onFieldPosted(response, name) {
        document.unlock(name)
    }

    function loadTrello(json) {
        document.set("taskID", json.id)
        document.set("name", json.name)
        document.set("completed", json.closed)
        document.set("dueDate", json.due === null ? new Date("") : json.due)
        if (json.idChecklists.length > 0)
            checklistID = json.idChecklists[0] // FIXME: support more than one checklist!
        else
            checklistID = ""
        document.set("description", json.badges.description ? json.desc : "")

        reloadFields()
    }

    function refresh() {

    }

    onChecklistIDChanged: {
        if (checklistID !== "") {
            httpGET("/checklists/" + checklistID, [], loadChecklist)
        }
    }

    function loadChecklist(response) {
        var json = JSON.parse(response)

        var items = json.checkItems
        checklist.clear()
        for (var i = 0; i < items.length; i++) {
            checklist.add(items[i].name, items[i].state === "complete")
        }
    }
}
