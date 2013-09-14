import QtQuick 2.0
import Ubuntu.Components 0.1
import U1db 1.0 as U1db

Object {
    id: root

    property string name
    property string docId: ""
    property var reload
    property var locked: []

    property var values: { return {} }

    property var children: { return {} }
    property var childrenDocs: []

    property var parent

    //Component.onCompleted: print("NEW DOCUMENT:", docId)

    onParentChanged: loadFromParent()
    onDocIdChanged: loadFromParent()

    function loadFromParent() {
        //print("Loading from parent:", root, name, docId)
        if (parent !== undefined && docId !== "") {
            //print("  Parent", parent.name, parent.docId)
            if (parent.childrenDocs === undefined)
                parent.childrenDocs = []

            var found = false
            for (var i = 0; i < parent.childrenDocs.length; i++) {
                if (parent.childrenDocs[i] === root) found = true
            }

            if (found) {
                console.log("FATAL: Document already exists!")
                Qt.quit()
            } else {
                parent.childrenDocs.push(root)
            }

            if (parent.children.hasOwnProperty(docId)) {
                load(parent.children[docId])
            }
        }
    }

    function get(name, def) {
        var value = values[name]
        return value !== undefined && value !== null ? value : def
    }

    function lock(name, value) {
        print("Locking", name, "with value", value)
        if (isLocked(name))
            locked.splice(locked.indexOf(name), 1)
        set(name, value)
        locked.push(name)
    }

    function unlock(name) {
        //print("Unlocking", name)
        if (isLocked(name))
            locked.splice(locked.indexOf(name), 1)
    }

    function setLocked(name, locked) {
        //print("Setting lock to", locked, "for", name)
        if (isLocked(name))
            locked.splice(locked.indexOf(name), 1)
        if (locked) {
            locked.push(name)
        }
    }

    function isLocked(name) {
        return locked.indexOf(name) !== -1
    }

    function set(name, value) {
        if (locked.indexOf(name) === -1) {
            debug("document", "Setting " + name + " to " + value)
            values[name] = value

            if (reload !== undefined)
                reload()
        } else {
            print("WARNING>>>>>>>>>>>>>>>>>>>>> FIELD IS LOCKED!!!!", name, value)
        }
    }

    function save() {
        var json = values

        if (childrenDocs != undefined) {
            //print("Sub documents:", childrenDocs)
            for (var i = 0; i < childrenDocs.length; i++) {
                //print("Found subdocument", childrenDocs[i].docId, "for", docId)
                children[childrenDocs[i].docId] = childrenDocs[i].save()
            }
        }

        if (listDocs().length > 0) {
            json.children = children
        }
        debug("document", "Saving: " + docId + " " + JSON.stringify(json))

        return json
    }

    function load(json) {
        //print("Loading", docId, JSON.stringify(json))

        if (json === undefined)
            return

        if (values === undefined)
            values = {}
        if (locked === undefined)
            locked = []

        if (json.hasOwnProperty("children")) {
            children = json.children
        }

        for (var key in json) {
            if (key !== "children")
                set(key, json[key])
        }

        if (childrenDocs !== undefined) {
            for (var i = 0; i < childrenDocs.length; i++) {
                childrenDocs[i].load(children[childrenDocs[i].docId])
            }
        }

        if (reload !== undefined)
            reload()
    }

    function remove(docId) {
        //print("Removing docId:", docId)
        if (children.hasOwnProperty(docId)) {
            //print("Deleting child item")
            delete children[docId]
        }

        for (var i = 0; i < childrenDocs.length; i++) {
            if (childrenDocs[i].docId === docId) {
                //print("Found subdoc, removing...")
                childrenDocs.splice(i, 1)
            }
        }
    }

    function listDocs() {
        var list = []

        for (var name in children) {
            list.push(name)
        }

        return list
    }
}
