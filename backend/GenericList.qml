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
    id: list

    /* Properties that define how the list works */

    property string docId               // The document ID used by U1db and optionally by other storage
    property string name                // The name of the list
    property string editable            // Can the list be deleted or renamed, or have tasks added?
    property var project

    onNameChanged:  fieldChanged("name", name)

    property bool updating: false       // Used to prevent sending changes to remote backend
                                        // when loading changes from the remote or local backend

    function fieldChanged(name, value) {
        if (!updating)
            document.lock(name, value)
    }

    property var lists: ListModel {
        id: lists
    }

    /* To be called after the document changes,
       either after loading from U1db or after loading from a remote model */
    function reloadFields() {
        print("Reloading list", name)
        updating = true

        name = document.get("name", "")

        updating = false
        print("Done.")
    }

    /* U1db Storage */

    Document {
        id: document
        parent: project.document
        docId: list.docId
        reload: reloadFields
    }

    function loadU1db() {
        // Implemented by individual backends...
    }
}
