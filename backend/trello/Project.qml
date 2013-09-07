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
import ".."

GenericProject {
    id: root

    property var boardID
    editable: true
    enabled: true
    property bool locked: false

    invalidActions: ["delete"]

    property var trelloFields: {
        "name": "name",
        "archived": "closed",
        "description": "desc",
    }

    onBoardIDChanged: {
        if (!updating)
            document.set("boardID", boardID)
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    customUploadFields: function() {
        boardID = document.get("boardID", "")
    }

    function fieldChanged(name, value) {
        if (!updating) {
            if (trelloFields.hasOwnProperty(name)) {
                document.lock(name, value)
                httpPUT("/board/" + boardID + "/" + trelloFields[name], ["value=" + value], onFieldPosted, name)
            } else {
                document.set(name, value)
            }
        }
    }

    function onFieldPosted(response, name) {
        document.unlock(name)
    }

    function loadTrello(json) {
        document.set("name", json.name)
        document.set("boardID", json.id)
        document.set("archived", json.closed)

        reloadFields()
    }

    function refresh() {
        httpGET("/boards/" + boardID + "/lists", [], loadLists)
    }

    function internal_newList() {
        if (!supportsLists) {
            console.log("FATAL: Creating lists is unsupported for", backend.name)
            Qt.quit()
        }
        //print("Adding new list...")
        var list = createList({
                          docId: nextDocId++
                      })
        internal_addList(list)
        list.loadU1db()
        return list
    }

    // For loading a project from U1db
    function loadListU1db(docId) {
        var list = createList({
                                        docId: docId
                                    })
        internal_addList(list)
        list.loadU1db()
        list.refresh()
        return list
    }

    function loadLists(response) {
        print("Loading lists...")
        var json = JSON.parse(response)

        for (var i = 0; i < json.length; i++) {
            var list = getList(json[i].id)
            if (list === undefined) {
                list = internal_newList()
                list.loadTrello(json[i])
                list.refresh()
            } else {
                list.loadTrello(json[i])
            }
        }

        for (var k = 0; k < lists.count; k++) {
            var found = false
            var list2 = lists.get(k).modelData
            if (list2.locked) return

            for (var j = 0; j < json.length; j++) {
                if (list2.listID === json[j].id) {
                    found = true
                    break
                }
            }

            if (!found)
                internal_removeList(list2)
        }
    }

    function getList(listID) {
        for (var i = 0; i < lists.count; i++) {
            if (lists.get(i).modelData.listID === listID)
                return lists.get(i).modelData
        }
    }

    listComponent: Component {

        List {

        }
    }
}
