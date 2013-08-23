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

Dialog {
    id: root

    title: i18n.tr("Select Date")

    text: i18n.tr("Please select a due date for '%1'").arg(task.title)

    property var task

    TextField {
        id: dateField

        text: Qt.formatDate(task.dueDate)

        placeholderText: i18n.tr("Date")

        onAccepted: okButton.clicked()
    }

    Button {
        id: okButton
        objectName: "okButton"

//        gradient: Gradient {
//            GradientStop {
//                position: 0
//                color: "green"//Qt.rgba(0,0.7,0,1)
//            }

//            GradientStop {
//                position: 1
//                color: Qt.rgba(0.3,0.7,0.3,1)
//            }
//        }

        text: i18n.tr("Ok")
        enabled: dateField.acceptableInput

        onClicked: {
            //print("User selected date:", dateField.text)

            if (dateField.text.toLowerCase() === i18n.tr("Today").toLowerCase()) {
                var today = new Date()
                today.setHours(0)
                today.setMinutes(0)
                today.setSeconds(0)
                task.dueDate = today
            } else {
                task.dueDate = new Date(dateField.text)
            }

            PopupUtils.close(root)
        }
    }

    Button {
        objectName: "cancelButton"
        text: i18n.tr("Cancel")

        gradient: Gradient {
            GradientStop {
                position: 0
                color: "gray"
            }

            GradientStop {
                position: 1
                color: "lightgray"
            }
        }

        onClicked: {
            PopupUtils.close(root)
        }
    }
}
