/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *                                                                         *
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

Column {
    id: root
    width: parent.width

    ProjectListItem {
        project: null
        selected: currentProject === null && !showingAssignedTasks
        onClicked: {
            currentProject = null
            showingAssignedTasks = false
        }
        visible: wideAspect && !showArchived
    }

    ProjectListItem {
        project: null
        selected: currentProject === null && showingAssignedTasks
        onClicked: {
            currentProject = null
            showingAssignedTasks = true
        }
        text: i18n.tr("In Progress")
        count: length(assignedTasks)
        visible: wideAspect && !showArchived
//        onCountChanged: {
//            if (count === 0)
//                showingAssignedTasks = false
//        }
    }

    ProjectListItem {
        project: uncategorizedProject
        visible: project !== null && !showArchived
    }

    Repeater {
        model: backendModels

        delegate: Column {
            width: parent.width
            visible: modelData.enabled && (showArchived ? modelData.archivedProjectsCount : modelData.openProjectsCount) > 0
            Header {
                text: modelData.name

                ProgressBar {
                    id: progressBar

                    anchors {
                        //left: parent.horizontalCenter
                        //leftMargin: units.gu(5)
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    width: 1/3 * parent.width

                    height: units.gu(2.5)

                    value: maximumValue - modelData.loading
                    minimumValue: 0
                    maximumValue: modelData.totalLoading
                    visible: maximumValue > 0
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

    property var filter: function(project) {
        return (showArchived === project.archived) && !project.special
    }

    property bool hasProjects: filteredSum(backendModels, "projects", filter) > 0
}
