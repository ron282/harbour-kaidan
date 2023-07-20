/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0
import "elements"

Page {
    id: root

    SilicaListView {
        id: rosterListView

        anchors.fill: parent
        VerticalScrollDecorator { flickable: rosterListView }

         PullDownMenu {
            MenuItem {
                id: searchAction
                text: qsTr("Search contacts")
                onClicked: {
                    searchField.forceActiveFocus()
                    searchField.selectAll()
                }
            }
        }

        header:
            Column {
                width: parent.width
                PageHeader {
                        title: {
                            Kaidan.connectionState === Enums.StateConnecting ? qsTr("Connecting…") :
                            Kaidan.connectionState === Enums.StateDisconnected ? qsTr("Offline") :
                            qsTr("Contacts")
                        }
                }
                SearchField
                {
                    id: searchField
                    //FIXME focusSequence: ""
                    width: parent.width
                    height: Theme.itemSizeLarge
                    onVisibleChanged: text = ""
                    onTextChanged: filterModel.setFilterFixedString(text.toLowerCase())
                }
            }

        model: RosterFilterProxyModel {
            id: filterModel
            sourceModel: RosterModel
        }

        delegate:
            RosterListItem {
                listView: rosterListView
                accountJid: AccountManager.jid
                jid: model ? model.jid : ""
                name: model ? (model.name ? model.name : model.jid) : ""
                lastMessage: model ? model.lastMessage : ""
                lastMessageIsDraft: model ? model.draftId : false
                unreadMessages: model ? model.unreadMessages : 0
                pinned: model ? model.pinned : false
                contentHeight: Theme.itemSizeMedium;

               menu: RosterListItemContextMenu {
                    id: itemContextMenu
                }

                onClicked: {
                    // Open the chatPage only if it is not yet open.
                    //if (!isSelected) {
                        openChatPage(accountJid, jid)
                    //}
                }
            }

            Connections {
                target: Kaidan

                function onOpenChatPageRequested(accountJid, chatJid) {
                    openChatPage(accountJid, chatJid)
                }
            }
        }

        /**
         * Opens the chat page for the chat JID currently set in the message model.
         *
         * @param accountJid JID of the account for that the chat page is opened
         * @param chatJid JID of the chat for that the chat page is opened
         */
        function openChatPage(accountJid, chatJid) {
            console.log("[rosterpage.qml] OpenChatPage called")

            MessageModel.setCurrentChat(accountJid, chatJid)

            pageStack.push(chatPage, {})
        }

        Component.onCompleted: {
            console.log("[rosterpage.qml] Roster Page completed")
        }
}
