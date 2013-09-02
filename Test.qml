import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "ubuntu-ui-extras"
import "backend/local"

MainView {
    property bool wideAspect: width > units.gu(80)

    width: units.gu(50)
    height: units.gu(75)

    Page {
        title: backend.name

        ListView {
            anchors.fill: parent

            model: backend.projects
            delegate: ListItem.SingleValue {
                text: modelData.name
                value: "?"
            }
        }
    }

    LocalBackend {
        id: backend
        name: "Projects"
    }

    Component.onCompleted: {
        backend.load()
        backend.newProject("Test")
        print("Documents:", backend.database.listDocs())
    }

    Component.onDestruction: backend.save()
}
