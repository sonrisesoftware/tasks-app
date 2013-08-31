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
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import U1db 1.0 as U1db

UbuntuShape {
    id: notification

    property var func
    property var args

    opacity: 0

    function show(text, icon, func, args) {
        notification.func = func
        notification.args = args
        label.text = text
        image.source = icon
        showAnimation.restart()
        timer.running = true
    }

    Timer {
        id: timer
        interval: 2500
        onTriggered: hideAnimation.restart()
    }

    NumberAnimation {
        duration: 200
        id: showAnimation
        target: notification
        property: "opacity"
        from: 0
        to: 1
    }

    NumberAnimation {
        duration: 500
        id: hideAnimation
        target: notification
        property: "opacity"
        from: 1
        to: 0
    }

    NumberAnimation {
        duration: 200
        id: clickedAnimation
        target: notification
        property: "opacity"
        from: 1
        to: 0
    }

    ListItem.Empty {
        Label {
            id: label
            text: "Undo"
            color: "gray"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: units.gu(2)
        }

        Image {
            id: image
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: units.gu(1.5)
                rightMargin: units.gu(2)
            }

            width: height
        }

        onTriggered: {
            hideAnimation.stop()
            timer.stop()
            clickedAnimation.restart()

            notification.func(notification.args)
        }
        showDivider: false
    }

    visible: opacity > 0
    color: "white"
    gradientColor: Qt.rgba(0.9,0.9,0.9,1)
    height: childrenRect.height

    anchors {
        margins: units.gu(2)
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
    }

    width: Math.min(units.gu(50), parent.width - units.gu(4))
}
