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

DefaultSheet {
    id: root

    title: i18n.tr("Statistics")

    doneButton: false

    function totalCount(date) {
        return countTasks(function(task) {
            return task.existedBy(date)
        })
    }

    Row {
        id: legendBar

        anchors {
            top: parent.top
            //left: parent.left
            horizontalCenter: parent.horizontalCenter
            margins: units.gu(2)
        }

        spacing: units.gu(3)

        Row {
            spacing: units.gu(1)
            UbuntuShape {
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(3)
                height: width
                color: labelColor("green")
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18n.tr("Completed")
                color: Theme.palette.normal.overlayText
            }
        }

        Row {
            spacing: units.gu(1)
            UbuntuShape {
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(3)
                height: width
                color: labelColor("yellow")
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18n.tr("Pending")
                color: Theme.palette.normal.overlayText
            }
        }

        Row {
            spacing: units.gu(1)
            UbuntuShape {
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(3)
                height: width
                color: labelColor("red")
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18n.tr("Overdue")
                color: Theme.palette.normal.overlayText
            }
        }
    }

    Rectangle {
        id: graph

        property int count: taskListModel.count + 1
        property int spacing: height/count

        anchors {
            top: legendBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(2)
            bottomMargin: units.gu(9)
        }

        border.color: "darkgray"

        Column {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }


            spacing: parent.spacing - 1

            Repeater {
                model: graph.count

                delegate: Rectangle {
                    color: index === graph.count - 1 ? "transparent" : "lightgray"
                    height: 1
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: 1
                    }
                }
            }
        }

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            spacing: units.gu(3)

            Repeater {
                id: graphBars
                model: Math.round((parent.parent.width + parent.spacing)/(units.gu(3) + parent.spacing), 0) - 1
                delegate: graphBar
            }
        }

        Component {
            id: graphBar

            Item {
                width: units.gu(3)
                height: childrenRect.height//doneRectangle.height + notDoneRectangle.height

                property date graphDate: {
                    var day = new Date()
                    day.setDate(day.getDate() - graphBars.count + index + 1)
                    print("GRAPH DATE:", Qt.formatDate(day))
                    print("GRAPH TOTAL THEN: ", totalCount(day))
                    return day
                }


                anchors {
                    bottom: parent.bottom
                    bottomMargin: 1
                }

                Item {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(-4)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(-1.4)
                    Label {
                        rotation: -90
                        text: formattedDate(graphDate)
                        color: Theme.palette.normal.overlayText
                    }
                }


                Rectangle {
                    id: doneRectangle
                    anchors {
                        bottom: parent.bottom
                    }

                    width: parent.width
                    height: countTasks(function(task) { return  task.completedBy(graphDate) }) * (graph.spacing)
                    color: labelColor("green")
                }

                Rectangle {
                    id: notDoneRectangle
                    anchors {
                        bottom: doneRectangle.top
                    }

                    width: parent.width
                    height: countTasks(function(task) { return task.notCompletedBy(graphDate) }) * (graph.spacing)
                    color: labelColor("yellow")
                }

                Rectangle {
                    id: overDueRectangle
                    anchors {
                        bottom: notDoneRectangle.top
                    }

                    width: parent.width
                    height: countTasks(function(task) { return task.overdueBy(graphDate) }) * (graph.spacing)
                    color: labelColor("red")
                }
            }
        }
    }
}
