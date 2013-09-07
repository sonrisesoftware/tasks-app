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
import "../ui"

SingleValue {
    id: root

    property var project

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        width: parent.width * 0.8

        Label {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight
            text: project === null
                  ? i18n.tr("Upcoming")
                  : project.name

            color: selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
            fontSize: "medium"
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            color: Theme.palette.normal.backgroundText
            fontSize: "small"
            //font.italic: true
            text: project === null ? "" : project.description
            visible: text !== ""
            elide: Text.ElideRight
        }
    }

//    text: project === null
//          ? i18n.tr("Upcoming")
//          : project.name

    onClicked: {
        if (project !== null)
            project.archived = false

        goToProject(project)
    }

    visible: project === null || (showArchived === project.archived && !project.special)

    selected: currentProject === project

    onPressAndHold: {
        print("PRESS AND HOLD!")
        if (project !== null && project.editable && !project.special)
            PopupUtils.open(projectPopover, root, {
                                project: project,
                                showGlobalActions: false
                            })
    }

    property int count: project === null ? length(upcomingTasks) : project.uncompletedCount

    value: count === 0 ? "" : count
}
