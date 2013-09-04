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
import U1db 1.0 as U1db

Item {
    id: project

    /* Properties that define how the project works */

    property string docId               // The document ID used by U1db and optionally by other storage
    property string name                // The name of the project
    property string description         // The description of the project
    property bool archived              // Is the project archived?
    property bool editable: backend.editable
    property bool supportsLists: backend.supportsLists
    property var backend
    property var upcomingTasks: concat(lists, "upcomingTasks")
    property var allTasks: concat(lists, "tasks")
    property int uncompletedCount: sum(lists, "uncompletedCount")

    property int nextDocId: 0
    property var listComponent

    onNextDocIdChanged: document.set("nextDocId", nextDocId)

    onNameChanged:  fieldChanged("name", name)
    onDescriptionChanged: fieldChanged("description", description)
    onArchivedChanged: fieldChanged("archived", archived)

    property bool updating: false       // Used to prevent sending changes to remote backend
                                        // when loading changes from the remote or local backend

    function fieldChanged(name, value) {
        if (!updating)
            document.set(name, value)
    }

    property var lists: ListModel {
        id: lists
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    function reloadFields() {
        //print("Reloading project", name)
        updating = true

        name = document.get("name", "")
        description = document.get("description", "")
        archived = document.get("archived", false)

        updating = false
        //print("Done.")
    }

    /* U1db Storage */

    property var document: Document {
        id: document
        name: "Project"
        parent: backend.database
        docId: project.docId
    }

    function loadU1db() {
        nextDocId = document.get("nextDocId", 0)
        reloadFields()

        var list = document.listDocs()
        //print("Child lists:", list)

        for (var i = 0; i < list.length; i++) {
            loadListU1db(list[i])
        }

        if (!supportsLists && lists.count !== 1) {
            //print("Creating default list...", lists.count)
            lists.clear()
            document.childrenDocs = []
            document.children = {}
            document.set("nextDocId", 0)
            nextDocId = 0
            var list = createList({
                              docId: nextDocId++
                          })
            list.name = i18n.tr("Tasks")
            internal_addList(list)
        }
    }

    /* Creation of new lists */

    // This is the front-end to creating new lists
    function newList(name) {
        if (!supportsLists) {
            console.log("FATAL: Creating lists is unsupported for", backend.name)
            Qt.quit()
        }
        //print("Adding new list...")
        var list = createList({
                          docId: nextDocId++
                      })
        list.name = name
        internal_addList(list)
        list.loadU1db()
        return list
    }

    // For loading a list from U1db
    function loadListU1db(docId) {
        var list = createList({
                                  docId: docId
                              })
        internal_addList(list)
        list.loadU1db()
        return list
    }

    // Creates a new list object
    function createList(args) {
        if (args === undefined)
            args = {}

        args.project = project

        var list = listComponent.createObject(project, args)

        if (list === null) {
            console.log("Unable to create:", newName)
        }

        return list
    }

    // This adds a list to the model
    function internal_addList(list) {
        if (list.project !== project)
            list.project = project
        if (list.docId === "")
            list.docId = nextDocId++
        //print("ADDING LIST", list.name, "to", name)
        lists.append({modelData: list})
    }

    /* Deletion of lists */

    // This is the front-end to removing lists
    function removeList(list) {
        // For implementation by backend...
        internal_removeList(list)
    }

    // This removes a list from the model
    function internal_removeList(list) {
        //print("Removing list...")
        document.remove(list.docId)
        for (var i = 0; i < lists.count; i++) {
            if (lists.get(i).modelData === list)
                lists.remove(i)
        }
    }

    /* DELETION OF THE PROJECT */

    function remove() {
        docId = ""
        //print("Deleting project...")
        backend.removeProject(project)
    }
}
