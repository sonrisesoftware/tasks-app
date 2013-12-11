/*
 * Project Dashboard - A project dashboard for Ubuntu Touch
 * Copyright (C) 2013 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../backend"

ComposerSheet {
    id: sheet

    property RepeatingDate date: RepeatingDate {

    }

    //__dimBackground: true

    Component.onCompleted: {
        sheet.__leftButton.text = i18n.tr("Close")
        sheet.__leftButton.gradient = UbuntuColors.greyGradient
        sheet.__rightButton.text = i18n.tr("Confirm")
        sheet.__rightButton.color = sheet.__rightButton.__styleInstance.defaultColor
        sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../components/SuruSheetStyle.qml"), sheet)
    }

//    SuruSheetStyle {
//        property SheetBase styledItem: root
//        anchors.fill: parent
//    }

    title: i18n.tr("Select Due Date")

    Flickable {
        id: flickable
        anchors {
            fill: parent
            margins: units.gu(-1)
        }
        clip: true
        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width

            ListItem.ValueSelector {
                text: i18n.tr("Repeats")
                values: [
                    i18n.tr("Never"),
                    i18n.tr("Daily"),
                    i18n.tr("Weekly"),
                    i18n.tr("Monthly")
                ]

                selectedIndex: {
                    if (date.repeats === "never") return 0
                    else if (date.repeats === "daily") return 1
                    else if (date.repeats === "weekly") return 2
                    else if (date.repeats === "monthly") return 3
                }

                onSelectedIndexChanged: {
                    print("Selected index =", selectedIndex)
                    if (selectedIndex === 0) date.repeats = "never"
                    else if (selectedIndex === 1) date.repeats = "daily"
                    else if (selectedIndex === 2) date.repeats = "weekly"
                    else if (selectedIndex === 3) date.repeats = "monthly"
                }
            }

            ListItem.Standard {
                text: i18n.tr("Repeats Every ")
                visible: date.repeats !== "never"

                TextField {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: repeatLabel.left
                        rightMargin: units.gu(1)
                    }

                    text: date.repeatsEvery

                    onTextChanged: {
                        if (text ==="")
                            date.repeatsEvery = 1
                        else
                            date.repeatsEvery = text
                    }

                    inputMethodHints: Qt.ImhDigitsOnly

                    hasClearButton: false
                    width: units.gu(10)
                }

                Label {
                    id: repeatLabel

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    text:{
                        var text = date.repeats === "daily"
                           ? i18n.tr("days")
                           : date.repeats === "weekly"
                             ? i18n.tr("weeks")
                             : date.repeats === "monthly"
                               ? i18n.tr("months")
                               : i18n.tr("years")
                        if (date.repeatsEvery === 1)
                            text = text.substring(0, text.length - 1)
                        return text
                    }
                }
            }

            ListItem.ValueSelector {
                visible: date.repeats !== "never" && date.repeats === "weekly"
                text: i18n.tr("Repeats On")
                values: {
                    var list = []
                    for (var i = 0; i < 7; i++) {
                        list.push(Qt.locale().dayName(i, Locale.LongFormat))
                    }

                    return list
                }
            }

            ListItem.SingleValue {
                visible: date.repeats !== "never"
                text: i18n.tr("Starts On")
                value: "12/13/13"
            }

            ListItem.ValueSelector {
                visible: date.repeats !== "never"
                text: i18n.tr("Ends")
                values: [
                    i18n.tr("Never"),
                    i18n.tr("After a number of times"),
                    i18n.tr("After a certain date")
                ]
            }

            ListItem.Standard {
                visible: date.repeats !== "never"
                text: i18n.tr("Ends after")

                TextField {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: endsLabel.left
                        rightMargin: units.gu(1)
                    }

                    text: "2"

                    hasClearButton: false
                    width: units.gu(10)
                }

                Label {
                    id: endsLabel

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    text: "repetitions"
                }
            }
        }
    }

    Scrollbar {
        flickableItem: flickable
    }
}
