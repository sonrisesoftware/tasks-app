/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to okd and the Father by him.                 *
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
import "Trello.js" as Trello

Dialog {
    id: root

    property alias value: textField.text
    property alias placeholderText: textField.placeholderText

    signal accepted()
    signal rejected()

    title: i18n.tr("Authenticate Trello")

    TextField {
        id: textField

        onAccepted: okButton.clicked()
        validator: RegExpValidator {
            regExp: /.+/
        }
    }

    Button {
        id: okButton
        objectName: "okButton"

        text: textField.acceptableInput ? i18n.tr("Ok") : i18n.tr("Authenticate")

        onClicked: {
            if (textField.acceptableInput) {
                PopupUtils.close(root)
                Trello.token = value
                saveSetting("trelloToken", value)
            } else {
                Trello.authenticate("Ubuntu Tasks")
            }

            accepted()
        }
    }

    Button {
        objectName: "cancelButton"
        text: i18n.tr("Cancel")

        gradient: UbuntuColors.greyGradient

        onClicked: {
            PopupUtils.close(root)
            rejected()
        }
    }
}
