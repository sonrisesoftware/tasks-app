.pragma library

var key = "333870c6f8dc97cb6a14e79dfe119675"
var secret = "1be63ceca6fcf130bfb61e68c9d85fcd9d1adeda3671fcee61d86d2bc236e7c3"
var token = ""
var responseText

function get(address, callback) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            print("RESPONSE:", doc.responseText)
            callback(doc.responseText)
        }
     }
    doc.open("GET", address);
    doc.send();
}

function call(path, options, callback) {
    get("https://trello.com/1" + path + "?key=" + key + "&token=" + token, callback)
}

function post(address, callback) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            callback(doc.responseText)
        }
     }
    doc.open("POST", address);
    doc.send();
}

function authenticate(name) {
    Qt.openUrlExternally("https://trello.com/1/authorize?" + /*"key=" +
                         key +*/
                         "&name=" + name.replace(" ", "+") + "&expiration=30days&response_type=token")
}
