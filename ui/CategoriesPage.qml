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

    title: i18n.tr("Categories")

    ListView {
        id: listView
        anchors.fill: parent
        model: categories

        delegate: Standard {
            id: categoryItem

            text: modelData
            onClicked: goToCategory(modelData)

            onPressAndHold: {
                PopupUtils.open(categoryActionsPopover, categoryItem, {
                                    category: modelData
                                })
            }
        }
    }

    Scrollbar {
        flickableItem: listView
    }

    Label {
        anchors.centerIn: parent
        visible: categories.length === 0

        fontSize: "large"
        text: i18n.tr("No categories!")
        opacity: 0.5
    }

    tools: ToolbarItems {
        ToolbarButton {
            iconSource: icon("add")
            text: i18n.tr("New")

            onTriggered: {
                PopupUtils.open(newCategoryDialog, caller)
            }
        }
    }

    Component {
        id: categoryActionsPopover

        ActionSelectionPopover {
            property string category

            actions: ActionList {
                Action {
                    text: i18n.tr("Rename")
                    onTriggered: {
                        PopupUtils.open(renameCategoryDialog, caller, {
                                            category: category
                                        })
                    }
                }

                Action {
                    text: i18n.tr("Delete")
                    onTriggered: {
                        removeCategory(category)
                    }
                }
            }
        }
    }
}
