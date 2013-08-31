/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *
 *                                                                         *
 * This program is free software: you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program. If not, see <http://www.gnu.org/licenses/>.    *
 ***************************************************************************/
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "../components"

Page {
    id: root

    title: showArchived ? i18n.tr("Archived Projects") : i18n.tr("Projects")

    property string type: "projects"

    property bool showArchived: false

    property bool hasProjects: filteredSum(backendModels, "projects", function(project) {
        return showArchived === project.archived
    }) > 0

    Flickable {
        id: flickable
        anchors.fill: parent

        // FIXME: REALLY uggly hack (no idea why)
        anchors.topMargin: -1
        topMargin: 1

        contentHeight: column.height
        contentWidth: width
        //clip: true

        Column {
            id: column
            width: parent.width

            Repeater {
                model: backendModels

                delegate: Column {
                    id: modelColumn
                    visible: modelData.enabled
                    width: parent.width
                    Header {
                        id: header
                        text: modelData.name
                        visible: count(modelData.projects, function(project) {
                            return showArchived === project.archived
                        }) > 0

                        ActivityIndicator {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: units.gu(2)
                            }

                            visible: running
                            running: modelData.loading > 0
                        }
                    }

                    Repeater {
                        model: modelData.projects

                        delegate: ProjectListItem {
                            project: modelData
                        }
                    }
                }
            }
        }
    }

    Label {
        id: noTasksLabel
        objectName: "noProjectsLabel"

        anchors.centerIn: parent

        visible: !hasProjects
        opacity: 0.5

        fontSize: "large"

        text: showArchived ? i18n.tr("No archived projects") : i18n.tr("No projects")
    }

    Scrollbar {
        flickableItem: flickable
    }

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: root.tools
                locked: true
                opened: true
            }
        }
    ]

    tools: ToolbarItems {
        id: tools
        Component.onCompleted: print("BACK:", tools.back.objectName)

        ToolbarButton {
            objectName: "newProject"
            iconSource: icon("add")
            text: i18n.tr("New Project")
            visible: !showArchived

            onTriggered: {
                newProject()
            }
        }

        Item {
            height: parent.height
            width: units.gu(0.5)
        }

        ToolbarButton {
            id: clearButton
            objectName: "clearArchive"

            text: i18n.tr("Clear")
            iconSource: icon("clear")
            visible: showArchived
            enabled: hasProjects

            onTriggered: {
                for (var i = 0; i < backendModels.length; i++) {
                    var backend = backendModels[i]
                    var index = 0;
                    //print("Removing tasks from", backend.name, backend.projects.count)
                    while (index < backend.projects.count) {
                        var project = get(backend.projects, index)

                        //print("Checking project:", index, project.name)

                        if (project.archived) {
                            //print("  Removed.")
                            project.remove()
                        } else {
                            index++
                        }
                    }
                }
            }
        }

        ToolbarButton {
            id: optionsButton
            objectName: "showArchive"

            text: i18n.tr("Archived")
            iconSource: icon("edit")
            visible: !showArchived

            onTriggered: {
                pageStack.push(Qt.resolvedUrl("ProjectsPage.qml"), {showArchived: true, objectName: "archivedProjectsPage"})
            }
        }
    }
}
