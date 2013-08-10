/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * SuperTask Pro - A task management system for Ubuntu Touch               *
 * Copyright (C) 2013 Michael Spencer <spencers1993@gmail.com>             *
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

Item {
    id: root

    height: childrenRect.height

    property Task task

    property var items: [
        {completed: true, text: "Test Item"},
        {completed: false, text: "ABC"}
    ]

    Column {
        id: contents
        anchors {
            left: parent.left
            right: parent.right
        }

        spacing: units.gu(1)

        Row {
            spacing: units.gu(2)

            width: parent.width

            Label {
                id: checklistLabel
                text: i18n.tr("Checklist")
                font.bold: true

                anchors.verticalCenter: parent.verticalCenter
            }

            ProgressBar {
                id: progressBar

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - checklistLabel.width - parent.spacing

                height: units.gu(3)

                value: 0
                minimumValue: 0
                maximumValue: root.items.length

                onValueChanged: {
                    if (value === maximumValue) {
                        task.completed = true
                    } else {
                        task.completed = false
                    }
                }
            }
        }


        Repeater {
            model: root.items

            delegate: ChecklistItem {
                listItem: modelData

                anchors {
                    left: parent.left
                    right: parent.right
                }

                onCompletedChanged: {
                    if (completed) {
                        progressBar.value += 1
                    } else {
                        progressBar.value -= 1
                    }
                }
            }
        }
    }
}
