import QtQuick 2.0

Item {
    id: root

    property string name
    property string index
    property bool archived
    property var project

    property var filter: function(task) {
        return task.listID === index
    }

    function load(json) {
        name = json.name
        index = json.index
        archived = json.archived
    }

    function loadTrello(json) {
        name = json.name
        index = json.id
        archived = json.closed
    }

    function save() {
        return {
            name: name,
            index: index,
            archived: archived
        }
    }
}
