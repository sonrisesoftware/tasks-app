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
import "../components"

Page {
    id: root

    title: i18n.tr("View Task")

    property Task task

    Column {
        anchors.fill: parent
        anchors.margins: units.gu(2)
        spacing: units.gu(2)

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }

            height: childrenRect.height

            Label {
                anchors {
                    left: parent.left
                    right: completedCheckBox.left
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                fontSize: "large"
                font.bold: true
                text: task.title
                elide: Text.ElideRight
            }

            CheckBox {
                id: completedCheckBox
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }

                checked: task.completed
                onCheckedChanged: task.completed = checked
            }
        }

        Label {
            visible: task.dueDate != null
            font.italic: true
            text: task.completed
                  ? i18n.tr("Completed %1").arg(formattedDate(task.completionDate))
                  : task.overdue
                    ? i18n.tr("Overdue (due %1)").arg(formattedDate(task.dueDate))
                    : i18n.tr("Due %1").arg(formattedDate(task.dueDate))
        }

        TextArea {
            anchors {
                left: parent.left
                right: parent.right
            }

            autoSize: true
            maximumLineCount: 23

            text: task.contents
            placeholderText: "No content."
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")
        }
    }
}
