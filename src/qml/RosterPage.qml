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

    Component {
        id: rosterFilteringDialog

        Dialog {
            DialogHeader {
                title: qsTr("Filter")
            }

            RosterFilteringArea {
                rosterFilterProxyModel: filterModel
            }
        }
    }

    Component {
        id: rosterFilteringPage

        Page {
            SilicaFlickable {
                PageHeader {
                    title: qsTr("Filter")
                }

                RosterFilteringArea {
                    rosterFilterProxyModel: filterModel
                }
            }
        }
    }

    SilicaListView {
        id: rosterListView
        PullDownMenu {
                MenuItem {
                    text: qsTr("Settings")
                    onClicked: {
                        pageStack.push(globalDrawer)
                    }
                }
                MenuItem {
                    text: qsTr("Search")
                    visible: isSearchActionShown
                    onClicked: {
                        toggleSearchBar()
                    }
                }
            }

        header:
            PageHeader {
                title: {
                    Kaidan.connectionState === Enums.StateConnecting ? qsTr("Connecting…") :
                    Kaidan.connectionState === Enums.StateDisconnected ? qsTr("Offline") :
                    qsTr("Contacts")
                }
            }


        anchors.fill: parent

        VerticalScrollDecorator { flickable: rosterListView }

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
            lastMessageIsDraft: model ? model.lastMessageIsDraft : false
            unreadMessages: model ? model.unreadMessages : 0
            pinned: model ? model.pinned : false
            notificationsMuted: model ? model.notificationsMuted : false
            contentHeight: Theme.itemSizeLarge;
            onClicked: {
                // Open the chatPage only if it is not yet open.
                if (!isSelected) {
                    Kaidan.openChatPageRequested(accountJid, jid)
                }
            }
        }

        Connections {
            target: Kaidan

            onOpenChatPageRequested: {
                console.log("[roster.qml] onOpenChatPageRequested")
/*                if (true) {
                    toggleSearchBar()
                } else {
                    searchField.text = ""
                }
*/
/*                for (var i = 0; i < pageStack.items.length; ++i) {
                    var page = pageStack.items[i];

                    if (page instanceof ChatPage) {
                        page.saveDraft();
                    }
                }
*/
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
}
