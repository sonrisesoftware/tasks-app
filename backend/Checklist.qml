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
        if (length > 0) {
            progress = 0
            for (var i = 0; i < length; i++) {
                if (items.get(i).modelData.completed)
                    progress += 1
            }

            if (progress === length)
                completed = true
            else
                completed = false
        }
        print("Progress", progress)
    }

    function load(json) {
        name = json.name
        items.clear()
        print("LOADING CHECKLIST:", name, json.items.length)

        for (var i = 0; i < json.items.length; i++) {
            print("   ", json.items[i])
            items.append({modelData: json.items[i]})
        }
        updateChecklistStatus()
    }

    function save() {
        var json = {}
        json.name = name
        json.items = []

        for (var i = 0; i < items.count; i++) {
            json.items.push(items.get(i).modelData)
        }
        print("SAVING CHECKLIST:", json)
        return json
    }

    function clear() {
        items.clear()
    }

    function add(name, completed) {
        if (completed === undefined)
            completed = false
        items.append({modelData: {name: name, completed: completed}})
        updateChecklistStatus()
    }

    function remove(index) {
        items.remove(index)
        updateChecklistStatus()
    }

    function setCompletion(index, completion) {
        print("Completed", index, completion)
        var item = items.get(index).modelData
        item.completed = completion
        items.set(index, {modelData: item})
        updateChecklistStatus()
    }

    function setName(index, name) {
        var item = items.get(index).modelData
        item.name = name
        items.set(index, {modelData: item})
        updateChecklistStatus()
    }
}
