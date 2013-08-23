/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>             *
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
import "../ui"

SingleValue {
    id: root

    property var project

    text: project === null
          ? i18n.tr("Upcoming")
          : project.name

    onClicked: {
        currentProject = project
        goToProject(project)
    }

    selected: currentProject === project
    enabled: project.enabled
    visible: !project.archived || showArchivedProjects

    onPressAndHold: {
        if (project !== null && project.editable)
            PopupUtils.open(projectActionsPopover, root, {
                                project: project
                            })
    }

    property int count: project === null ? upcomingTasks.length : project.uncompletedTasks.length

    value: count === 0 ? "" : count
}
