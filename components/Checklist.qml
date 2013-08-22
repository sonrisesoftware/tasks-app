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

ListView {
    id: root

    height: contentHeight
    interactive: false

    property var task
    model: task.checklist

    header: Header {
        Label {
            id: checklistLabel
            text: i18n.tr("Checklist")

            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
        }

        ProgressBar {
            id: progressBar

            anchors {
                left: parent.horizontalCenter
                //leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            //width: units.gu(20)

            height: units.gu(2.5)

            value: task.progress
            minimumValue: 0
            maximumValue: task.checklist.length
        }
    }

    delegate: ChecklistItem {
        itemIndex: index
        checklist: task.checklist

        anchors {
            left: parent.left
            right: parent.right
        }
    }

    footer: Standard {
        anchors {
            left: parent.left
            right: parent.right
        }

        text: i18n.tr("Add item")

        onClicked: {
            var list = task.checklist
            list.push({completed: false, text: "New Item"})
            task.checklist = list
            //repeater.children.get(repeater.model.length - 1).editing = true
        }
    }
}
