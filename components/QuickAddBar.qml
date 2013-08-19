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
import "../ui"

Rectangle {
    id: addBar

    property bool expanded: visible

    color: Qt.rgba(0.5,0.5,0.5,0.8)

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        bottomMargin: expanded ? 0 : -addBar.height

        Behavior on bottomMargin {
            UbuntuNumberAnimation { }
        }
    }

    implicitHeight: addField.height + addBarDivider.height + units.gu(2)

    ThinDivider {
        id: addBarDivider

        anchors {
            left: parent.left
            right: parent.right
            bottom: addField.top
            bottomMargin: units.gu(1)
        }
    }

    TextField {
        id: addField
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
        }

        placeholderText: i18n.tr("Add New Task")

        onAccepted: {
            addTask({title: addField.text, category: root.category})
            addField.text = ""
        }
    }
}
