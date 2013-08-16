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
import "../components"

Page {
    id: root

    title: task.category === "" ? i18n.tr("Uncategorized") : task.category

    property Task task

    property string type: "task"

//    property color headerColor: labelHeaderColor(task.label)
//    property color backgroundColor: labelColor(task.label)
//    property color footerColor: labelFooterColor(task.label)


    TaskItem {
        id: taskItem
        visible: task != null
        task: root.task
        anchors.fill: parent
    }

    Item {
        anchors.fill: parent

        Label {
            anchors.centerIn: parent
            visible: task === null

            fontSize: "large"
            text: i18n.tr("No task selected")
            opacity: 0.5
        }
    }

    Scrollbar {
        flickableItem: taskItem
    }

    tools: ToolbarItems {
        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")
            onTriggered: PopupUtils.open(confirmDeleteTaskDialog, root)
        }
    }

    Component {
        id: confirmDeleteTaskDialog

        ConfirmDialog {
            id: confirmDeleteTaskDialogItem
            title: i18n.tr("Delete Task")
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(task.title)

            onAccepted: {
                var task = root.task
                PopupUtils.close(confirmDeleteTaskDialogItem)
                goToCategory(task.category)
                task.remove()
            }
        }
    }

    Component {
        id: confirmDeleteCategoryDialog

        ConfirmDialog {
            id: confirmDeleteCategoryDialogItem
            title: i18n.tr("Delete Category")
            text: i18n.tr("Are you sure you want to delete '%1'?").arg(category)

            onAccepted: {
                PopupUtils.close(confirmDeleteCategoryDialogItem)
                clearPageStack()
                removeCategory(category)
            }
        }
    }
}
