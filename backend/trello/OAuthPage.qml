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
import QtWebKit 3.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "Trello.js" as Trello

Page {
    id: webPage
    property string token: ""

    WebView {
        anchors.fill: parent
        url: webPage.visible ? "https://trello.com/" : ""
        onUrlChanged: {
            console.log("Oauth token getter url is now : " + url)
            console.log("Oauth token getter url is now : " + typeof url.toString())
            print ("RETURNED URL: ", url.toString())
//            if (url.toString().substring(0, 32) === "https://api.github.com/zen?code=") {
//                webPage.token = url.toString().substring(32)
//                // move this to a database?
//                console.log("Oauth token is now : " + webPage.token)
//                pageStack.pop();
//            }
        }
    }
}
