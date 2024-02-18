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
    z: 1
    width: parent.width

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

    Component {
        id: searchPublicGroupChatSheet
        SearchPublicGroupChatSheet {}
    }
    Component {
        id: settingsSheet
        SettingsSheet {}
    }

    Column {
        id: mainCol
        width: parent.width
        spacing: Theme.paddingMedium

        PageHeader {
            title: qsTr("Kaidan")
        }

        SectionHeader {
            text: qsTr("Accounts")
        }

        ColumnView {
            model: [ AccountManager.jid ]
            itemHeight: Theme.iconSizeMedium + Theme.itemSizeSmall
            width: parent.width

            delegate:
                Column {
                    spacing: 0

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.horizontalPageMargin

                    Row {
                        id: accountArea
                        width: parent.width
                        height: Theme.iconSizeMedium
                        property bool disconnected: Kaidan.connectionState === Enums.StateDisconnected
                        property bool connected: Kaidan.connectionState === Enums.StateConnected
                        Avatar {
                            jid: AccountManager.jid
                            name: AccountManager.displayName
                            width: Theme.iconSizeMedium
                            height: width
                        }
                        TextSwitch {
                            automaticCheck: false
                            width: parent.width - 2*Theme.iconSizeMedium
                            text: AccountManager.displayName
                            description: Kaidan.connectionStateText
                            highlighted: accountArea.connected
                            checked: !accountArea.disconnected
                            onClicked: {
                                checked: !checked
                                accountArea.disconnected ? Kaidan.logIn() : Kaidan.logOut()
                            }
                        }
                        IconButton {
                            icon.source: "image://theme/icon-m-edit"
                            onClicked: {
                                openViewFromGlobalDrawer(accountDetailsSheet, accountDetailsPage)
                            }
                        }
                        Label {
                            id: errorMessage
                            width: parent.width
                            visible: Kaidan.connectionError
                            text: Kaidan.connectionError ? Utils.connectionErrorMessage(Kaidan.connectionError) : ""
                            color: Theme.errorColor
                            font.pixelSize: Theme.fontSizeTiny
                            wrapMode: Text.WordWrap
                        }
                    } // Row
                } // Column
        } // ColumnView

        SectionHeader {
                text: qsTr("Actions")
        }

        ButtonLayout {
            Button {
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text : qsTr("Add contact by QR code")
                icon.source: "image://theme/icon-m-qr"
                onClicked: {
                    pageStack.push(qrCodePage)
                }
            }
            Button {
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Add contact by address")
                icon.source: "image://theme/icon-m-new"
                onClicked: openContactAdditionView()
            }

            Button {
                visible: false // To debug
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                id: publicGroupChatSearchButton
                text: qsTr("Search public groups")
                icon.source: "image://theme/icon-m-search"
                onClicked: {
                    pageStack.push(searchPublicGroupChatSheet)
                }
            }

            Button {
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Invite friends")
                icon.source: "image://theme/icon-s-invitation"
                icon.height: Theme.iconSizeMedium
                icon.width: Theme.iconSizeMedium
                onClicked: {
                    Utils.copyToClipboard(Utils.invitationUrl(AccountManager.jid))
                    passiveNotification(qsTr("Invitation link copied to clipboard"))
                }
            }

            Button{
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Switch device")
                icon.source: "image://theme/icon-m-device"
                onClicked: {
                    pageStack.push("AccountTransferPage.qml")
                }
            }

            Button {
                visible: false // To debug
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Multimedia Settings")
                //FIXME description: qsTr("Configure photo, video and audio recording settings")
                onClicked: pageStack.push("qrc:/qml/settings/MultimediaSettings.qml")
                icon.source: "image://theme/icon-m-setting"
            }

            Button {
                width:Theme.buttonWidthLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("About Kaidan")
                //FIXME description: qsTr("Learn about the current Kaidan version, view the source code and contribute")
                onClicked: pageStack.push("qrc:/qml/settings/AboutPage.qml")
                icon.source: "image://theme/icon-m-about"
            }
        }
    }

    //onExpandedChanged: {
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
          popLayersAboveLowest()
          if (pageStack.currentPage != root) {
              console.log("pageStack.currentPage != root")
              pageStack.navigateBack(PageStackAction.Immediate)
          }

          return openView(overlayComponent, pageComponent)
    }

    Connections {
        target: Kaidan

        onCredentialsNeeded: {
            accountDetailsSheet.close()
            close()
        }

        onXmppUriReceived: {
            const xmppUriPrefix = "xmpp:"
            openContactAdditionView().jid = uri.substr(xmppUriPrefix.length)
        }
    }
}
