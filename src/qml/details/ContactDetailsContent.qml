// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami
// import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import im.kaidan.kaidan 1.0

import "../elements"

DetailsContent {
	id: root

	property bool isChatWithOneself: MessageModel.currentAccountJid === jid

	encryptionArea: Column {
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
            text: qsTr("OMEMO 0")
			//FIXME description: qsTr("End-to-end encryption with OMEMO 2 ensures that nobody else than you and your chat partners can read or modify the data you exchange.")
			enabled: MessageModel.usableOmemoDevices.length
			checked: MessageModel.isOmemoEncryptionEnabled
			// The switch is toggled by setting the user's preference on using encryption.
			// Note that 'checked' has already the value after the button is clicked.
            onClicked: MessageModel.encryption = checked ? Encryption.Omemo0 : Encryption.NoEncryption
		}

		Button {
			text: {
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
			icon.source: {
				if (!MessageModel.usableOmemoDevices.length) {
					if (accountOmemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-device-lock"
					} else if (ownResourcesWatcher.resourcesCount > 1) {
                        return "image://theme/icon-m-warning"
					} else if (root.isChatWithOneself) {
                        return "image://theme/icon-m-warning"
					}
				} else if (accountOmemoWatcher.authenticatableOmemoDevices.length) {
					if (accountOmemoWatcher.authenticatableOmemoDevices.length === accountOmemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-device-lock"
					}

                    return "image://theme/icon-m-device-lock"
				}

				return ""
			}
			visible: text
			enabled: accountOmemoWatcher.authenticatableOmemoDevices.length
			onClicked: pageStack.layers.push(qrCodePage, { isForOwnDevices: true })

			UserResourcesWatcher {
				id: ownResourcesWatcher
				jid: AccountManager.jid
			}
		}

		Button {
			text: {
				if(root.isChatWithOneself) {
					return ""
				}

				if (!MessageModel.usableOmemoDevices.length) {
					if (contactOmemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR code of your <b>contact</b> to enable encryption")
					}

					return qsTr("Your <b>contact</b> doesn't use OMEMO 2")
				} else if (contactOmemoWatcher.authenticatableOmemoDevices.length) {
					if (contactOmemoWatcher.authenticatableOmemoDevices.length === contactOmemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR codes of your <b>contact's</b> devices to encrypt for them")
					}

					return qsTr("Scan the QR code of your <b>contact</b> for maximum security")
				}

				return ""
			}
			icon.source: {
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
			visible: text
			enabled: contactOmemoWatcher.authenticatableOmemoDevices.length
			onClicked: pageStack.layers.push(qrCodePage, { contactJid: root.jid })
		}
	}

    Dialog {
		id: qrCodeDialog
		z: 1000

		Column {
			QrCode {
				jid: root.jid
				//FIXME Layout.fillHeight: true
				width: parent.width
				//FIXME Layout.preferredWidth: 500
				// //FIXME Layout.preferredHeight: 500
                //Layout.maximumHeight: applicationWindow().height * 0.5
			}
		}
	}

	SilicaFlickable {
		width: parent.width

        Column {
			spacing: 0

			SectionHeader {
                text: qsTr("Sharing")
			}

			Button {
				text: qsTr("Show QR code")
				//FIXME description: qsTr("Share this contact's chat address via QR code")
                icon.source: "image://theme/icon-m-qr"
				onClicked: qrCodeDialog.open()
			}

			Button {
				text: qsTr("Copy chat address")
				//FIXME description: qsTr("Share this contact's chat address via text")
                icon.source: "image://theme/icon-m-send"
				onClicked: {
					Utils.copyToClipboard(Utils.trustMessageUri(root.jid))
					passiveNotification(qsTr("Contact copied to clipboard"))
				}
			}
		}
	}

	RosterItemWatcher {
		id: contactWatcher
		jid: root.jid
	}

	SilicaFlickable {
		width: parent.width

         Column {
			spacing: 0

			SectionHeader {
                text: qsTr("Notifications")
			}

			TextSwitch {
				text: qsTr("Incoming messages")
				//FIXME description: qsTr("Show notification and play sound on message arrival")
				checked: !mutedWatcher.muted
				onCheckedChanged: mutedWatcher.muted = !mutedWatcher.muted

				NotificationsMutedWatcher {
					id: mutedWatcher
					jid: root.jid
				}
			}
		}
	}

	SilicaFlickable {
		width: parent.width

         Column {
			spacing: 0

			SectionHeader {
                text: qsTr("Privacy")
			}

			Button {
				text: qsTr("Request status")
				//FIXME description: qsTr("Request contact's availability, devices and other personal information")
				visible: !contactWatcher.item.sendingPresence
				onClicked: Kaidan.client.rosterManager.subscribeToPresenceRequested(root.jid)
			}

			TextSwitch {
				text: qsTr("Send status")
				//FIXME description: qsTr("Provide your availability, devices and other personal information")
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
				//FIXME description: qsTr("Indicate when you have this conversation open, are typing and stopped typing")
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
				//FIXME description: qsTr("Indicate which messages you have read")
				checked: contactWatcher.item.readMarkerSendingEnabled
				onCheckedChanged: {
					RosterModel.setReadMarkerSendingEnabled(
						MessageModel.currentAccountJid,
						MessageModel.currentChatJid,
						checked)
				}
			}
		}
	}

	SilicaFlickable {
		width: parent.width

         Column {
			spacing: 0

			SectionHeader {
                text: qsTr("Removal")
			}

			Column {
				spacing: 0

                IconTextSwitch {
					id: removalButton
					text: qsTr("Remove")
					//FIXME description: qsTr("Remove contact and complete chat history")
                    icon.source: "image://theme/icon-m-edit"
					icon.color: "red"
					onCheckedChanged: contactRemovalCorfirmButton.visible = !contactRemovalCorfirmButton.visible
				}

				Button {
					id: contactRemovalCorfirmButton
					text: qsTr("Confirm")
					visible: false
                    anchors.leftMargin: Theme.paddingLarge
					onClicked: {
						visible = false
						removalButton.enabled = false
						Kaidan.client.rosterManager.removeContactRequested(jid)
					}
				}
			}
		}
	}
}
