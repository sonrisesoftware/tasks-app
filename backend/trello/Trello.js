.pragma library

var key = "333870c6f8dc97cb6a14e79dfe119675"
var secret = "1be63ceca6fcf130bfb61e68c9d85fcd9d1adeda3671fcee61d86d2bc236e7c3"
var token = ""
var model
var responseText

function call(path, options, callback) {
    get(path, options, callback)
}

function post(path, options, callback) {
    request(path, "POST", options, callback)
}

function put(path, options, callback) {
    request(path, "PUT", options, callback)
}

function get(path, options, callback) {
    request(path, "GET", options, callback)
}

function request(path, call, options, callback) {
    var address = "https://trello.com/1" + path + "?key=" + key + "&token=" + token
    if (options.length > 0)
        address += "&" + options.join("&").replace(" ", "+")

    print(call, address)

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            model.loading--
            print(call, path, options.join("&").replace(" ", "+"))
            print(doc.responseText)
            if (callback !== undefined)
                callback(doc.responseText)
        }
     }

    doc.open(call, address);
    //doc.setRequestHeader("Accept", "application/json")
    doc.send();

    model.loading++
}

function authenticate(name) {
    Qt.openUrlExternally("https://trello.com/1/authorize?" + "key=" +
                         key + "&name=" + name.replace(" ", "+") +
                         "&expiration=30days&response_type=token&scope=read,write")
}
