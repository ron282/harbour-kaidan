// SPDX-FileCopyrightText: 2016 Marzanna <MRZA-MRZA@users.noreply.github.com>
// SPDX-FileCopyrightText: 2016 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Robert Maerkisch <zatrox@kaidan.im>
// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 caca hueto <cacahueto@olomono.de>
// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbblp@protonmail.ch>
// SPDX-FileCopyrightText: 2022 Bhavy Airi <airiragahv@gmail.com>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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

        RosterListItemContextMenu {
            id: itemContextMenu
        }

        delegate: RosterListItem {
            listView: rosterListView
            contextMenu: itemContextMenu
            accountJid: AccountManager.jid
            jid: model ? model.jid : ""
            name: model ? (model.name ? model.name : model.jid) : ""
            lastMessage: model ? model.lastMessage : ""
            lastMessageIsDraft: model ? model.draftId : false
            unreadMessages: model ? model.unreadMessages : 0
            pinned: model ? model.pinned : false
            contentHeight: Theme.itemSizeLarge;
            onClicked: {
                // Open the chatPage only if it is not yet open.
//                if (!isSelected || !wideScreen) {
//                    Kaidan.openChatPageRequested(accountJid, jid)
//                }

                MessageModel.setCurrentChat(accountJid, jid)

                // Close all pages (especially the chat page) except the roster page.
                while (pageStack.depth > 1) {
                    pageStack.pop()
                }

                popLayersAboveLowest()
                pageStack.push(chatPage)
            }
        }

        Connections {
            target: Kaidan

            function onOpenChatPageRequested(accountJid, chatJid) {
                console.log("[roster.qml] onOpenChatPageRequested")
//                if (Kirigami.Settings.isMobile) {
                    toggleSearchBar()
//				} else {
//					searchField.text = ""
//				}

//				for (let i = 0; i < pageStack.items.length; ++i) {
//					let page = pageStack.items[i];
//
//					if (page instanceof ChatPage) {
//						page.saveDraft();
//					}
//				}

                MessageModel.setCurrentChat(accountJid, chatJid)

                // Close all pages (especially the chat page) except the roster page.
                while (pageStack.depth > 1) {
                    pageStack.pop()
                }

                popLayersAboveLowest()
                pageStack.push(chatPage)
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
        console.log("[openChatPageterpage.qml] Roster Page completed")
    }
}
