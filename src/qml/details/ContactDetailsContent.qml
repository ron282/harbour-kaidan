// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"

DetailsContent {
	id: root

	property bool isChatWithOneself: MessageModel.currentAccountJid === jid

    mediaOverview {
        accountJid: MessageModel.currentAccountJid
        chatJid: MessageModel.currentChatJid
    }


    vCardRepeater {
        model: VCardModel {
            jid: root.jid
        }
        delegate: BackgroundItem {
            id: vCardDelegate

            Column {
                width: parent.width
                Label {
                    text: Utils.formatMessage(model.value)
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    visible: !vCardDelegate.editMode
                    width: parent.width
                    rightPadding: Theme.paddingLarge
                    leftPadding: Theme.paddingLarge
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                Label {
                    text: model.key
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    width: parent.width
                    rightPadding: Theme.paddingLarge
                    leftPadding: Theme.paddingLarge
                }
            }
        }
    }


    rosterGroupArea: Column {
        id: colRoster
        width: parent.width

        SectionHeader {
            text: qsTr("Labels")
        }
        TextField {
            id: rosterGroupField
            placeholderText: qsTr("New label")
            enabled: !rosterGroupBusyIndicator.running
            width: parent.width
//          onAccepted: rosterGroupAdditionButton.clicked()

            rightItem: IconButton {
                id: rosterGroupAdditionButton
                icon.source: "image://theme/icon-splus-add"
                enabled: rosterGroupField.text.length
                visible: !rosterGroupBusyIndicator.running
                onClicked: {
                    var groups = []

                    groups = chatItemWatcher.item.groupsList

                    if (groups.indexOf(rosterGroupField.text) !== -1) {
                        rosterGroupField.text = ""
                    } else if (enabled) {
                        rosterGroupBusyIndicator.running = true

                        groups.push(rosterGroupField.text)
                        Kaidan.client.rosterManager.updateGroupsRequested(root.jid, chatItemWatcher.item.name, groups)

                        rosterGroupField.text = ""
                    } else {
                        rosterGroupField.forceActiveFocus()
                    }
                }
            }
            BusyLabel {
                text: qsTr("updating labels...")
                anchors.fill: parent
                id: rosterGroupBusyIndicator
            }
        }

        Connections {
            target: rosterGroupListView

            onVisibleChanged: {
                if (rosterGroupListView.visible) {
                    rosterGroupField.text = ""
                    rosterGroupField.forceActiveFocus()
                }
            }
        }

        Connections {
            target: RosterModel

            onGroupsChanged: {
                rosterGroupBusyIndicator.running = false
                rosterGroupField.forceActiveFocus()
            }
        }

        ColumnView {
            id: rosterGroupListView
            model: RosterModel.groups
            visible: true // rosterGroupExpansionButton.checked
            itemHeight: Theme.itemSizeSmall
            delegate: TextSwitch {
                id: rosterGroupDelegate
                text: modelData
                checked: contactWatcher.item.groupsList.includes(modelData)
                width: parent.width
                height: Theme.itemSizeSmall
                onCheckedChanged:  {
                    var groups = contactWatcher.item.groupsList

                    if (checked) {
                        groups.push(modelData)
                    } else {
                        groups.splice(groups.indexOf(modelData), 1)
                    }

                    Kaidan.client.rosterManager.updateGroupsRequested(root.jid, contactWatcher.item.name, groups)
                }
            }

            // TODO: Remove this and see TODO in RosterModel once fixed in Kirigami Addons.
            Connections {
                target: RosterModel

                onGroupsChanged: {
                    // Update the "checked" value of "rosterGroupDelegate" as a work
                    // around because "MobileForm.FormSwitchDelegate" does not listen to
                    // changes of "contactWatcher.item.groups".
                    rosterGroupDelegate.checked = contactWatcher.item.groupsList.includes(modelData)
                }
            }
        }
    }

    encryptionArea: Column {
        width: parent.width
		spacing: 0

		OmemoWatcher {
			id: accountOmemoWatcher
			jid: AccountManager.jid
		}

		OmemoWatcher {
			id: contactOmemoWatcher
			jid: root.jid
		}

		SectionHeader {
            text: qsTr("Encryption")
		}

		TextSwitch {
            text: qsTr("OMEMO")
            description: qsTr("End-to-end encryption with OMEMO ensures that nobody else than you and your chat partners can read or modify the data you exchange.")
			enabled: MessageModel.usableOmemoDevices.length
			checked: MessageModel.isOmemoEncryptionEnabled
			// The switch is toggled by setting the user's preference on using encryption.
			// Note that 'checked' has already the value after the button is clicked.
            onClicked: MessageModel.encryption = checked ? Encryption.Omemo0 : Encryption.NoEncryption
		}

        ValueButton {
            label: {
				if (!MessageModel.usableOmemoDevices.length) {
					if (accountOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan your devices")
					} else if (ownResourcesWatcher.resourcesCount > 1) {
                        return qsTr("No scan for your devices")
					} else if (root.isChatWithOneself) {
                        return qsTr("No scan for your devices")
					}
				} else if (accountOmemoWatcher.authenticatableOmemoDevices.length) {
					if (accountOmemoWatcher.authenticatableOmemoDevices.length === accountOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan your devices")
					}

                    return qsTr("Scan your devices")
				}

				return ""
			}
            description: {
                if (!MessageModel.usableOmemoDevices.length) {
                    if (accountOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
                    } else if (ownResourcesWatcher.resourcesCount > 1) {
                        return qsTr("<b>Your</b> other devices don't use OMEMO 0")
                    } else if (root.isChatWithOneself) {
                        return qsTr("<b>You</b> have no other devices supporting OMEMO 0")
                    }
                } else if (accountOmemoWatcher.authenticatableOmemoDevices.length) {
                    if (accountOmemoWatcher.authenticatableOmemoDevices.length === accountOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
                    }

                    return qsTr("Scan the QR codes of <b>your</b> devices for maximum security")
                }

                return ""
            }
//            icon.source: {
//               if (!MessageModel.usableOmemoDevices.length) {
//					if (accountOmemoWatcher.distrustedOmemoDevices.length) {
//                        return "image://theme/icon-m-vpn"
//					} else if (ownResourcesWatcher.resourcesCount > 1) {
//                        return "image://theme/icon-m-warning"
//					} else if (root.isChatWithOneself) {
//                        return "image://theme/icon-m-warning"
//					}
//				} else if (accountOmemoWatcher.authenticatableOmemoDevices.length) {
//					if (accountOmemoWatcher.authenticatableOmemoDevices.length === accountOmemoWatcher.distrustedOmemoDevices.length) {
//                        return "image://theme/icon-m-device-lock"
//					}
//
//                    return "image://theme/icon-m-device-lock"
//				}
//
//				return ""
//			}

            visible: label
			enabled: accountOmemoWatcher.authenticatableOmemoDevices.length
            onClicked: pageStack.push(qrCodePage, { isForOwnDevices: true })

			UserResourcesWatcher {
				id: ownResourcesWatcher
				jid: AccountManager.jid
			}
		}

        ValueButton {
            label: {
                if(root.isChatWithOneself) {
                    return ""
                }

                if (!MessageModel.usableOmemoDevices.length) {
                    if (contactOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan contact")
                    }

                    return qsTr("No scan for contact")
                } else if (contactOmemoWatcher.authenticatableOmemoDevices.length) {
                    if (contactOmemoWatcher.authenticatableOmemoDevices.length === contactOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan contact")
                    }

                    return qsTr("Scan contact")
                }

                return ""
            }
            description: {
                if(root.isChatWithOneself) {
                    return ""
                }

                if (!MessageModel.usableOmemoDevices.length) {
                    if (contactOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan the QR code of your <b>contact</b> to enable encryption")
                    }

                    return qsTr("Your <b>contact</b> doesn't use OMEMO")
                } else if (contactOmemoWatcher.authenticatableOmemoDevices.length) {
                    if (contactOmemoWatcher.authenticatableOmemoDevices.length === contactOmemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan the QR codes of your <b>contact's</b> devices to encrypt for them")
                    }

                    return qsTr("Scan the QR code of your <b>contact</b> for maximum security")
                }

                return ""
            }
/*			icon.source: {
				if (!MessageModel.usableOmemoDevices.length) {
					if (contactOmemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-warning"
					}

                    return "image://theme/icon-m-warning"
				} else if (contactOmemoWatcher.authenticatableOmemoDevices.length) {
					if (contactOmemoWatcher.authenticatableOmemoDevices.length === contactOmemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-warning"
					}

                    return "image://theme/icon-m-device-lock"
				}

				return ""
			}
*/
            visible: label
			enabled: contactOmemoWatcher.authenticatableOmemoDevices.length
            onClicked: pageStack.push(qrCodePage, { contactJid: root.jid })
		}
    }

    Component {
        id: qrCodeDialog
        Dialog {
    //	z: 1000
            Column {
                width: parent.width
                DialogHeader { title: qsTr("QR Code") }

                QrCode {
                    jid: root.jid
                    height:  Screen.height * 0.5 // Math.min(parent.height, Screen.height * 0.5)
                    width: parent.width
                }
            }
        }
    }

    RosterItemWatcher {
        id: contactWatcher
        jid: root.jid
    }

    extraContentArea: Column {
        spacing: 0
        width: parent.width

        SectionHeader {
            text: qsTr("Sharing")
        }

        ValueButton {
            label: qsTr("Show QR code")
            description: qsTr("Share this contact's chat address via QR code")
//            icon.source: "image://theme/icon-m-qr"
            onClicked: pageStack.push(qrCodeDialog)
        }

        ValueButton {
            label: qsTr("Copy chat address")
            description: qsTr("Share this contact's chat address via text")
//            icon.source: "image://theme/icon-m-send"
            onClicked: {
                Utils.copyToClipboard(Utils.trustMessageUri(root.jid))
                passiveNotification(qsTr("Contact copied to clipboard"))
            }
        }

        SectionHeader {
            text: qsTr("Notifications")
        }

        TextSwitch {
            text: qsTr("Incoming messages")
            description: qsTr("Show notification and play sound on message arrival")
            checked: !contactWatcher.item.notificationsMuted

            onCheckedChanged: {
                RosterModel.setNotificationsMuted(
                    MessageModel.currentAccountJid,
                    MessageModel.currentChatJid,
                    !checked)
            }
        }

        SectionHeader {
            text: qsTr("Privacy")
        }

        ValueButton {
            label: qsTr("Request status")
            description: qsTr("Request contact's availability, devices and other personal information")
            visible: !contactWatcher.item.sendingPresence
            onClicked: Kaidan.client.rosterManager.subscribeToPresenceRequested(root.jid)
        }

        TextSwitch {
            text: qsTr("Send status")
            description: qsTr("Provide your availability, devices and other personal information")
            checked: contactWatcher.item.receivingPresence
            visible: !isChatWithOneself
            onCheckedChanged: {
                if (checked) {
                    Kaidan.client.rosterManager.acceptSubscriptionToPresenceRequested(MessageModel.currentChatJid)
                } else {
                    Kaidan.client.rosterManager.refuseSubscriptionToPresenceRequested(MessageModel.currentChatJid)
                }
            }
        }

        TextSwitch {
            text: qsTr("Send typing notifications")
            description: qsTr("Indicate when you have this conversation open, are typing and stopped typing")
            checked: contactWatcher.item.chatStateSendingEnabled
            onCheckedChanged: {
                RosterModel.setChatStateSendingEnabled(
                    MessageModel.currentAccountJid,
                    MessageModel.currentChatJid,
                    checked)
            }
        }

        TextSwitch {
            text: qsTr("Send read notifications")
            description: qsTr("Indicate which messages you have read")
            checked: contactWatcher.item.readMarkerSendingEnabled
            onCheckedChanged: {
                RosterModel.setReadMarkerSendingEnabled(
                    MessageModel.currentAccountJid,
                    MessageModel.currentChatJid,
                    checked)
            }
        }

        SectionHeader {
            text: qsTr("Removal")
        }

        IconTextSwitch {
            id: removalButton
            text: qsTr("Remove")
            description: qsTr("Remove contact and complete chat history")
            icon.source: "image://theme/icon-m-delete"
            icon.color: "red"
            onCheckedChanged: contactRemovalCorfirmButton.visible = !contactRemovalCorfirmButton.visible
        }

        Button {
            id: contactRemovalCorfirmButton
            text: qsTr("Confirm")
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.buttonWidthMedium
            onClicked: {
                visible = false
                removalButton.enabled = false
                Kaidan.client.rosterManager.removeContactRequested(jid)
            }
        }
    }
}
