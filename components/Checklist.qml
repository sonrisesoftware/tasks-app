/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
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

Column {
    id: root

    property var task


    Header {
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

            value: 0
            minimumValue: 0
            maximumValue: task.checklist.length

            onMaximumValueChanged: {
                if (value === maximumValue && maximumValue !== 0) {
                    task.completed = true
                } else {
                    task.completed = false
                }
            }

            onValueChanged: {
                if (value === maximumValue && maximumValue !== 0) {
                    task.completed = true
                } else {
                    task.completed = false
                }
            }
        }
    }


    Repeater {
        id: repeater
        model: task.checklist

        delegate: ChecklistItem {
            itemIndex: index
            checklist: task.checklist

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

    Standard {
        anchors {
            left: parent.left
            right: parent.right
        }

        text: i18n.tr("Add item")

        onClicked: {
            print("CLICKED!")
            var list = task.checklist
            list.push({completed: false, text: "New Item"})
            task.checklist = list
            //repeater.children.get(repeater.model.length - 1).editing = true
        }
    }
}
