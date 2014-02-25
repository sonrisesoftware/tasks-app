import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "../backend/trello" as Trello

DefaultSheet {
    id: sheet

    title: i18n.tr("Settings")

    Component.onCompleted: {
        sheet.__leftButton.text = i18n.tr("Close")
        //sheet.__leftButton.gradient = UbuntuColors.greyGradient
        //sheet.__rightButton.text = i18n.tr("Confirm")
        //sheet.__rightButton.color = sheet.__rightButton.__styleInstance.defaultColor
        sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../ubuntu-ui-extras/SuruSheetStyle.qml"), sheet)
    }

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: -units.gu(1)

        ListItem.Standard {
            text: i18n.tr("Connect to Trello")

            control: Switch {
                checked: trelloIntegration
                onCheckedChanged: {
                    saveSetting("trelloIntegration", checked ? "true" : "false")
                    checked = Qt.binding(function() { return trelloIntegration })
                    if (trelloIntegration) {
                        if (getSetting("trelloToken", "") === "") {
                            PopupUtils.open(trelloAuthentication, root)
                        } else {
                            goToProjects()
                            if (!trello.loaded)
                                trello.load()
                        }
                    }
                }
            }
        }

        ListItem.Standard {
            text: i18n.tr("About Ubuntu Tasks")
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    Component {
        id: trelloAuthentication

        Trello.TrelloAuthenticationDialog {
            onAccepted: {
                goToProjects()
                trello.connect()
            }
            onRejected: trelloIntegration = false
        }
    }
}
