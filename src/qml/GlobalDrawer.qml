// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2018 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "elements"
import "details"
import "settings"

Page {
    id: root

    Component {
        id: qrCodePage

        QrCodePage {}
    }

    Component {
        id: accountDetailsSheet

        AccountDetailsSheet {}
    }

    Component {
        id: accountDetailsPage

        AccountDetailsPage {}
    }

    SearchPublicGroupChatSheet {
        id: searchPublicGroupChatSheet
    }

    SettingsSheet {
        id: settingsSheet
    }

    Column {
        spacing: Theme.paddingLarge

        SectionHeader {
            text: qsTr("Accounts")
        }

        ColumnView {
            model: [ AccountManager.jid ]

            delegate: Column {
                spacing: 0

                Row {
                    id: accountArea

                    Avatar {
                        jid: AccountManager.jid
                        name: AccountManager.displayName
                        width: Theme.iconSizeMedium
                    }

                    ValueButton {
                        property bool disconnected: Kaidan.connectionState === Enums.StateDisconnected
                        property bool connected: Kaidan.connectionState === Enums.StateConnected

                        label: AccountManager.displayName
                        value: Kaidan.connectionStateText
                        valueColor: connected ? Theme.highlightColor: Theme.primaryColor

                        onClicked: {
                            root.close()
                            openViewFromGlobalDrawer(accountDetailsSheet, accountDetailsPage)
                        }
                    }
                    Switch {
                        checked: !accountArea.disconnected
                        onCheckedChanged: accountArea.disconnected ? Kaidan.logIn() : Kaidan.logOut()
                    }
               }

                Label {
                    id: errorMessage
                    visible: Kaidan.connectionError
                    text: Kaidan.connectionError ? Utils.connectionErrorMessage(Kaidan.connectionError) : ""
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
                }
            }
        }

        SectionHeader {
            text: qsTr("Actions")
        }

        Button {
            text: qsTr("Add contact by QR code")
            icon.source: "image://theme/icon-m-qr"
            onClicked: {
                root.close()
                pageStack.layers.push(qrCodePage)
            }
        }

        Button {
            text: qsTr("Add contact by chat address")
            icon.source: "image://theme/icon-m-new"
            onClicked: openContactAdditionView()
        }

        Button {
            id: publicGroupChatSearchButton
            text: qsTr("Search public groups")
            icon.source: "image://theme/icon-m-search"
            onClicked: {
                root.close()
                searchPublicGroupChatSheet.open()
            }
        }

        Button {
            text: qsTr("Invite friends")
            icon.source: "image://theme/icon-s-invitation"
            onClicked: {
                Utils.copyToClipboard(Utils.invitationUrl(AccountManager.jid))
                passiveNotification(qsTr("Invitation link copied to clipboard"))
            }
        }

        Button{
            text: qsTr("Switch device")
            icon.source: "image://theme/icon-m-device"
            onClicked: {
                root.close()
                pageStack.layers.push("AccountTransferPage.qml")
            }
        }

        Button {
            text: qsTr("Settings")
            icon.source: "image://theme/icon-m-setting"
            onClicked: {
                root.close()

                if (pageStack.layers.depth < 2)
                    pageStack.layers.push(settingsPage)
            }
        }

    onStatusChanged: {
        if (Kaidan.connectionState === Enums.StateConnected) {
            // Request the user's current vCard which contains the user's nickname.
            Kaidan.client.vCardManager.clientVCardRequested()
        }

        // Retrieve the user's own OMEMO key to be used while adding a contact via QR code.
        // That is only done when no chat is already open.
        // Otherwise, it would result in an unneccessary fetching and it would remove the cached
        // keys for that chat while only keeping the own key in the cache.
        if (!MessageModel.currentChatJid.length) {
            Kaidan.client.omemoManager.retrieveOwnKeyRequested()
        }
    }

    function openContactAdditionView() {
        return openViewFromGlobalDrawer(contactAdditionDialog, contactAdditionPage)
    }

    function openViewFromGlobalDrawer(overlayComponent, pageComponent) {
        root.close()
        return openView(overlayComponent, pageComponent)
    }

    Connections {
        target: Kaidan

        function onCredentialsNeeded() {
            accountDetailsSheet.close()
            close()
        }

        function onXmppUriReceived(uri) {
            const xmppUriPrefix = "xmpp:"
            openContactAdditionView().jid = uri.substr(xmppUriPrefix.length)
        }
    }
}
