
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import "../components"
import "../ubuntu-ui-extras"

Popover {
    id: root
    property var project

    property bool showGlobalActions: false

    contentHeight: contents.height + units.gu(2)

    Column {
        id: contents
        spacing: units.gu(0)
        anchors {
            margins: units.gu(0)
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: units.gu(2)
        }

        Column {
            spacing: units.gu(2)
            anchors {
                margins: units.gu(2)
                left: parent.left
                right: parent.right
            }

//            TextField {
//                id: nameTextArea
//                width: parent.width

//                Component.onCompleted: __styleInstance.color = nameLabel.color

//                readOnly: project === null || project.special || !project.canEdit("description")
//                text: project !== null ? project.name : i18n.tr("Upcoming")
//                placeholderText: i18n.tr("Project Name")

//                onFocusChanged: {
//                    __styleInstance.color = (focus ? Theme.palette.normal.overlayText : nameLabel.color)

//                    if (focus) {
//                        text = Qt.binding(function() { return project.name})
//                    } else {
//                        project.name = text
//                    }
//                }
//            }

            EditableLabel {
                id: nameLabel
                text: project !== null ? project.name : i18n.tr("Upcoming")
                placeholderText: i18n.tr("Project Name")
                width: parent.width
                overlay: true
                editable: project !== null && !project.special && project.canEdit("name")
                onDoneEditing: {
                    project.name = text
                    text = Qt.binding(function() { return project.name })
                }
            }

            TextArea {
                id: descriptionTextArea
                width: parent.width

                Component.onCompleted: __styleInstance.color = nameLabel.color

                readOnly: project === null || project.special || !project.canEdit("description")
                text: project ? project.description : i18n.tr("A list of upcoming tasks from all your projects.")
                placeholderText: i18n.tr("Description")

                onFocusChanged: {
                    __styleInstance.color = (focus ? Theme.palette.normal.overlayText : nameLabel.color)

                    if (focus) {
                        text = Qt.binding(function() { return project.description})
                    } else {
                        project.description = text
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: units.gu(2)
        }

        ThinDivider {
            visible: archiveAction.visible || deleteAction.visible
        }

        OverlayStandard {
            id: archiveAction
            text: i18n.tr("Archive")
            visible: project !== null && !project.special && project.canEdit("archived")
            showDivider: deleteAction.visible
        }

        OverlayStandard {
            id: deleteAction
            text: i18n.tr("Delete")
            visible: project !== null && !project.special && project.supportsAction("delete")
            showDivider: false
        }

        Divider {
            visible: newAction.visible
        }

        OverlayStandard {
            id: newAction
            text: i18n.tr("New Project...")
            visible: showGlobalActions

            showDivider: false
        }
    }
}
