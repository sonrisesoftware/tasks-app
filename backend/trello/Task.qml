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
    property string listID
    property string listName: project.getList(listID)
    property bool locked: false

    nonEditableFields: {
        var fields = ["repeat", "tags", "checklist", "priority"]
        if (!(project.hasList("To Do") && project.hasList("Done"))) fields.push("completed")

        if (!project.hasList("Doing")) fields.push("assignedTo")

        return fields
    }

    invalidActions: ["move"]

    property var trelloFields: {
        "name": "name",
        "listID": "idList",
        "description": "desc",
        "dueDate": "due",
        "tags": "labels",
        "assignedTo": "idMembers"
    }

    onListNameChanged: {
        if (!updating) {
            debug("task", name + " LIST NAME CHANGED TO " + listName)
            if (listName === "Done") {
                completed = true
            } else if (listName != ""){
                completed = false
            }
        }
    }

    onAssignedToChanged: {
        if (!updating) {
            if (assignedTo === "") {
                if (listName !== "To Do") listID = project.getListByName("To Do")
            } else {
                if (listName !== "Doing") listID = project.getListByName("Doing")
            }
        }
    }

    onCompletedChanged: {
        if (!updating) {
            debug("task", name + " COMPLETED CHANGED TO " + completed)
            if (completed) {
                if (listName !== "Done") listID = project.getListByName("Done")
            } else {
                if (assignedTo === "") {
                    if (listName !== "To Do") listID = project.getListByName("To Do")
                } else {
                    if (listName !== "Doing") listID = project.getListByName("Doing")
                }
            }
        }
    }

    onTaskIDChanged: {
        if (!updating)
            document.set("taskID", taskID)
    }

    onListIDChanged: {
        fieldChanged("listID", listID)
    }

    customUploadFields: function() {
        taskID = document.get("taskID", "")
        listID = document.get("listID", "")
    }

    function fieldChanged(name, value) {
        if (!updating) {
            if (trelloFields.hasOwnProperty(name)) {
                document.lock(name, value)
                if (name === "dueDate" && Qt.formatDate(value) === "") {
                    httpPUT("/cards/" + taskID + "/" + trelloFields[name], ["value=" + null], onFieldPosted, name)
                } else if (name === "tags") {
                    var list = []
                    for (var i = 0; i < value.length; i++) {
                        list.push({color: tags[i], name: project.getTag(tags[i])})
                    }

                    print("Setting labels as", JSON.stringify(list))
                    httpPUT("/cards/" + taskID + "/" + trelloFields[name], ["value=" + JSON.stringify(list)], onFieldPosted, name)
                } else {
                    httpPUT("/cards/" + taskID + "/" + trelloFields[name], ["value=" + value], onFieldPosted, name)
                }
            } else {
                document.set(name, value)
            }
        }
    }

    function onFieldPosted(response, name) {
        print(response)
        print("Unlocked", name)
        document.unlock(name)
    }

    function loadTrello(json) {
        document.set("taskID", json.id)
        document.set("name", json.name)
        document.set("listID", json.idList)
        document.set("assignedTo", json.idMembers[0])
        var labels = json.labels
        var list = []
        for (var i = 0; i < labels.length; i++) {
            list.push(labels[i].color)
            //project.setTag(labels[i].color, labels[i].name)
        }
        document.set("tags", list)

        document.set("dueDate", json.due === null ? new Date("") : json.due)
        if (json.idChecklists.length > 0)
            checklistID = json.idChecklists[0] // FIXME: support more than one checklist!
        else
            checklistID = ""
        document.set("description", json.badges.description ? json.desc : "")

        debug("task", "Reloading Trello!")
        reloadFields()
    }

    function refresh() {

    }

    onChecklistIDChanged: {
        if (checklistID !== "") {
            httpGET("/checklists/" + checklistID, [], loadChecklist)
        }
    }

    updateChecklistStatus: function() {
        var json = []

        //httpPUT()
    }

    function loadChecklist(response) {
        var json = JSON.parse(response)

        updating = true

        var items = json.checkItems
        checklist.clear()
        for (var i = 0; i < items.length; i++) {
            checklist.add(items[i].name, items[i].state === "complete")
        }

        updating = false

        if (checklist.progress === checklist.length) {
            completed = true
        } else {
            completed = false
        }
    }
}
