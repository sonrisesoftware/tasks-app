import QtQuick 2.0

QtObject {
    id: root
    property string repeats: "never" // or "daily", "weekly", or "monthly"
    property int repeatsEvery: 1
    property int repeatsOn: 1 // Monday
    property string ends: "never" // or "reps" or "date"
    property var endsValue
    property var startDate: new Date()

    property var date
    property int completed

    function dueNext() {
        if (date === undefined)
            date = next()
        return date
    }

    function toJSON() {
        return {}
    }

    function update() {
        date = undefined
        date = next()
    }

    function next() {
        var date = root.date
        if (date !== undefined)
            completed++

        if (date === undefined) {
            date = startDate
        } else if (repeats === "never") {
            date = undefined
        } else if (repeats == "daily") {
            date.setDate(date.getDate() + repeatsEvery)
        } else if (repeats === "weekly") {
            while (dayOfWeek(date) !== repeatsOn)
                date.setDate(date.getDate() + 1)
        }

        if (ends === "reps") {
            if (completed >= endsValue)
                date = undefined
        } else if (ends === "date") {
            if (dateIsBefore(endsValue, date))
                date = undefined
        }

        return date
    }

    function dayOfWeek(date) {
        var list = []
        for (var i = 0; i < 7; i++) {
            list.push(Qt.locale().dayName(i, Locale.LongFormat))
        }
        var day = Qt.formatDate(date, "dddd")
        return list.indexOf(day)
    }
}
