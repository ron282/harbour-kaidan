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
// SPDX-FileCopyrightText: 2024 ron282 <ronan35@gmx.fr>
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
            Column {
                width: parent.width
                DialogHeader {
                    title: qsTr("Filter")
                }

                RosterFilteringArea {
                    rosterFilterProxyModel: filterModel
                }
            }
        }
    }

    Component {
        id: rosterFilteringPage

        Page {
            SilicaFlickable {
                anchors.fill: parent
                contentHeight: column.height

                Column {
                    id: column
                    width: parent.width

                    PageHeader {
                        title: qsTr("Filter")
                    }

                    RosterFilteringArea {
                        rosterFilterProxyModel: filterModel
                    }
                }
            }
        }
    }

    SilicaListView {
        id: rosterListView

        PullDownMenu {
                MenuItem {
                    text: qsTr("Search")
                    visible: false // isSearchActionShown
                    onClicked: {
                        toggleSearchBar()
                    }
                }
                MenuItem {
                    text: qsTr("Filter")
                    onClicked: openView(rosterFilteringDialog, rosterFilteringPage)
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

        anchors {
            fill: parent
        }

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
            menu: itemContextMenu
            accountJid: AccountManager.jid
            jid: model ? model.jid : ""
            name: model ? (model.name ? model.name : model.jid) : ""
            lastMessage: model ? model.lastMessage : ""
            lastMessageIsDraft: model ? model.lastMessageIsDraft : false
            lastMessageSenderId: model ? model.lastMessageSenderId : ""
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

            /**
             * Opens the chat page for the chat JID currently set in the message model.
             *
             * @param accountJid JID of the account for that the chat page is opened
             * @param chatJid JID of the chat for that the chat page is opened
             */
             onOpenChatPageRequested: {
//				if (Kirigami.Settings.isMobile) {
//                    toggleSearchBar()
//				} else {
//					searchField.text = ""
//				}

                MessageModel.setCurrentChat(accountJid, chatJid)

                closePagesExceptRosterPage()
                popLayersAboveLowest()
                pageStack.push(chatPage)
            }

            onCloseChatPageRequested: {
                closePagesExceptRosterPage()
                resetChatView()
            }

            /**
             * Closes all pages (especially the chat page) on the same layer except the roster page.
             */
            function closePagesExceptRosterPage() {
                popAllPages()

                pageStack.push(globalDrawer, {}, PageStackAction.Immediate)
                pageStack.pushAttached(rosterPage, {}, PageStackAction.Immediate)
                pageStack.navigateForward(PageStackAction.Immediate)
                pageStack.completeAnimation()
            }
        }
    }
}
