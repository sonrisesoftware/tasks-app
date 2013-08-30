import QtQuick 2.0
import Ubuntu.Components 0.1
import U1db 1.0 as U1db

Object {
    id: root

    property string docId
    property var reload
    property var locked: []

    property var values: { return {} }

    property var children: { return {} }
    property var childrenDocs: []

    property var parent

    onParentChanged: {
        if (parent !== undefined) {
            print(parent)
            print("Loading from parent:", docId, parent.docId)
            if (parent.childrenDocs === undefined)
                parent.childrenDocs = []
            parent.childrenDocs.push(root)
            if (!parent.children.hasOwnProperty(docId)) {
                print("Creating child...")
                parent.children[docId] = {}
            }

            load(parent.children[docId])
        }
    }

    function get(name, def) {
        var value = values[name]
        return value === undefined ? def : value
    }

    function lock(name, value) {
        print("Locking", name, "with value", value)
        if (isLocked(name))
            locked.splice(locked.indexOf(name), 1)
        set(name, value)
        locked.push(name)
    }

    function unlock(name) {
        print("Unlocking", name)
        if (isLocked(name))
            locked.splice(locked.indexOf(name), 1)
    }

    function setLocked(name, locked) {
        print("Setting lock to", locked, "for", name)
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
        if (get(name) !== value && locked.indexOf(name) === -1) {
            values[name] = value

            if (reload !== undefined)
                reload()
        }
    }

    function save() {
        var json = values

        for (var i = 0; i < childrenDocs.length; i++) {
            children[childrenDocs[i].docId] = childrenDocs[i].save()
        }

        json.children = children
        print("Saving", docId, JSON.stringify(json))

        return json
    }

    function load(json) {
        print("Loading", docId, JSON.stringify(json))
        values = json
        if (json.hasOwnProperty("children")) {
            children = json.children
        }

        if (childrenDocs !== undefined) {
            for (var i = 0; i < childrenDocs.length; i++) {
                childrenDocs[i].load(children[childrenDocs[i].docId])
            }
        }

        if (reload !== undefined)
            reload()
    }

    function listDocs() {
        var list = []

        for (var name in children) {
            list.push(name)
        }

        return list
    }
}
