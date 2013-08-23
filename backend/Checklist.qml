import QtQuick 2.0

QtObject {
    id: checklist

    property ListModel items: ListModel {
        id: items

        onDataChanged: updateChecklistStatus()
    }

    property alias length: items.count
    property int progress: 0

    property int percent: progress * 100/checklist.length

    property string name: i18n.tr("Checklist")

    function updateChecklistStatus() {
        if (length === 0) {
            if (hasChecklist) {
                completed = false
            }
        } else {
            progress = 0
            for (var i = 0; i < length; i++) {
                if (items.get(i).completed)
                    progress += 1
            }

            if (progress === length)
                completed = true
            else
                completed = false
        }
    }

    function load(json) {
        name = json.name
        items.clear()

        for (var i = 0; i < json.items.count; i++) {
            items.append({modelData: json.items[i]})
        }
    }

    function save() {
        var json = {}
        json.name = name
        json.items = []

        for (var i = 0; i < items.count; i++) {
            json.items.push(items.get(i).modelData)
        }
        print("CHECKLIST:", json)
        return json
    }

    function add(name) {
        items.append({modelData: {name: name, completed: false}})
    }

    function remove(index) {
        items.remove(index)
    }

    function setCompletion(index, completion) {
        var item = items.get(index).modelData
        items.set(index, {modelData: {}})
        item.completion = completion
        items.set(index, item)
    }

    function setName(index, name) {
        var item = items.get(index).modelData
        items.set(index, {modelData: {}})
        item.name = name
        items.set(index, item)
    }
}
