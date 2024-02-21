// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbblp@protonmail.ch>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "elements"

/**
 * This page is used for authenticating encryption keys by scanning QR codes or entering key IDs.
 */
ExplanationOptionsTogglePage {
	id: root

	property string accountJid
	property string chatJid
	readonly property bool forOwnDevices: accountJid === chatJid

	title: qsTr("Verify devices")
    explanationInitiallyVisible: Kaidan.settings.keyAuthenticationPageExplanationVisible
	primaryButton.text: state === "primaryAreaDisplayed" ? qsTr("Show explanation") : qsTr("Scan QR codes")
	primaryButton.onClicked: {
		if (Kaidan.settings.keyAuthenticationPageExplanationVisible) {
			// Hide the explanation when this page is opened again in the future.
			Kaidan.settings.keyAuthenticationPageExplanationVisible = false

			if (!qrCodeScanningArea.scanner.cameraEnabled) {
				qrCodeScanningArea.scanner.cameraEnabled = true
			}
		}
	}
	secondaryButton.text: state === "secondaryAreaDisplayed" ? qsTr("Show explanation") : qsTr("Verify manually")
	explanation: ExplanationArea {
		primaryExplanationText.text: root.forOwnDevices ? qsTr("Step 1: Scan your <b>other device's</b> QR code") : qsTr("Step 1: Scan your <b>contact's</b> QR code")
		primaryExplanationImage.source: Utils.getResourcePath(root.forOwnDevices ? "images/qr-code-scan-own-1.svg" : "images/qr-code-scan-1.svg")
		secondaryExplanationText.text: root.forOwnDevices ? qsTr("Step 2: Scan with your other device <b>this device's</b> QR code") : qsTr("Step 2: Let your contact scan <b>your</b> QR code")
		secondaryExplanationImage.source: Utils.getResourcePath(root.forOwnDevices ? "images/qr-code-scan-own-2.svg" : "images/qr-code-scan-2.svg")
	}
	primaryArea: QrCodeScanningArea {
		id: qrCodeScanningArea
		accountJid: root.accountJid
		chatJid: root.chatJid
		visible: !Kaidan.settings.keyAuthenticationPageExplanationVisible
        anchors.centerIn: parent
	}
    secondaryArea: Flow {
		anchors.fill: parent
        flow: parent.width > parent.height ? Flow.LeftToRight : Flow.TopToBottom
        spacing: Theme.paddingSmall
        property int rowSpacing: spacing
        property int columnSpacing: rowSpacing

        EncryptionDevicesArea {
			id: contactDevicesArea
			header.text: root.forOwnDevices ? qsTr("Unverified own devices") : qsTr("Unverified contact devices")
			listView.model: OmemoModel {
				jid: root.chatJid
            }
            listView.spacing: Theme.paddingMedium
			listView.header: Row {
                width: ListView.view.width
//             height: encryptionKeyField.height
//				Kirigami.Theme.colorSet: Kirigami.Theme.Window
//				contentItem: MobileForm.AbstractFormDelegate {
//					background: Item {}

                        TextArea {
							id: encryptionKeyField
							onTextChanged: text = Utils.displayableEncryptionKeyId(text)
							placeholderText: "899bdd30 74f346c3 34cec4bb 536be448 c33886f3 057a912a 1f299b0f 32193d6c"
                            font.family: "monospace"
                            inputMethodHints: Qt.ImhPreferLatin | Qt.ImhPreferLowercase | Qt.ImhLatinOnly
							enabled: !encryptionKeyBusyIndicator.visible
							font.pixelSize: Theme.fontSizeExtraSmall
							textLeftMargin: 0
							softwareInputPanelEnabled: false
							width: parent.width - encryptionKeyAuthenticationButton.width - parent.spacing
//							onAccepted: encryptionKeyAuthenticationButton.clicked()
							onClicked: {
								Qt.inputMethod.show()
								forceActiveFocus()
							}
						}

						IconButton {
							id: encryptionKeyAuthenticationButton
//							Controls.ToolTip.text: qsTr("Verify device")
                            icon.source: "image://theme/icon-m-add"
							visible: !encryptionKeyBusyIndicator.visible
//							flat: !hovered
//							Layout.rightMargin: Kirigami.Units.largeSpacing
							onClicked: {
								// Remove empty spaces from the key ID and convert it to lower case.
								const keyId = encryptionKeyField.text.replace(/\s/g, "").toLowerCase()

								if (Utils.validateEncryptionKeyId(keyId)) {
									encryptionKeyBusyIndicator.visible = true

									if (contactDevicesArea.listView.model.contains(keyId)) {
										Kaidan.client.atmManager.makeTrustDecisionsRequested(contactDevicesArea.listView.model.jid, [keyId], [])

										encryptionKeyField.text = ""
										passiveNotification(qsTr("Device verified"))
									} else {
										passiveNotification(qsTr("Device does not exist or is already verified"))
									}

									encryptionKeyBusyIndicator.visible = false
								} else {
									passiveNotification(qsTr("The fingerprint must have 64 characters with digits and letters from a to f"))
								}

								encryptionKeyField.forceActiveFocus()
							}
						}

						BusyIndicator {
							id: encryptionKeyBusyIndicator
							visible: false
                            width: encryptionKeyAuthenticationButton.width
                            height: encryptionKeyAuthenticationButton.height
						}
			}
			
            listView.delegate: BackgroundItem {
				width: ListView.view.width
				height: colDevice.height
				Column {
					id: colDevice
					width: parent.width
					Label {
						text: model.label ? model.label : qsTr("no device name")
						font.pixelSize: Theme.fontSizeSmall
						width: parent.width
					}
					Row {
						width: parent.width
						Label {
							text: Utils.displayableEncryptionKeyId(model.keyId)
							wrapMode: Label.WordWrap
							width: parent.width - buttonAddKey.width - parent.spacing
							font.pixelSize: Theme.fontSizeExtraSmall
							font.family: "monospace"
							color: Theme.secondaryColor
						}
						IconButton {
							id: buttonAddKey
							icon.source: "image://theme/icon-m-add"
							onClicked: {
								Kaidan.client.atmManager.makeTrustDecisionsRequested(contactDevicesArea.listView.model.jid, [model.keyId], [])
								passiveNotification(qsTr("Device verified"))
							}
						}
					}
				}
			}
		}

		Separator {
			width: parent.flow === Flow.TopToBottom ? parent.width : 1
			height: parent.flow === Flow.LeftToRight? parent.height : 1
		}

		EncryptionDevicesArea {
			header.text: qsTr("Verified own devices")
			listView.spacing: Theme.paddingMedium
			listView.model: OmemoModel {
				jid: root.accountJid
				ownAuthenticatedKeysProcessed: true
			}
			listView.delegate: BackgroundItem {
				width: ListView.view.width
				height: encryptionKeyDelegate.height
				Column {
					id: encryptionKeyDelegate
					width: parent.width
					Label {
						width: parent.width
						text: model.label ? model.label : qsTr("no device name")
						font.pixelSize: Theme.fontSizeSmall
					}
                    Row {
                        width: parent.width
                        Label {
                            id: encryptionKeyText
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.family: "monospace"
                            wrapMode: Label.WordWrap
                            text: Utils.displayableEncryptionKeyId(model.keyId)
    //						descriptionItem.textFormat: Text.MarkdownText
                            color: Theme.secondaryColor
                            width: parent.width - encryptionKeyCopyButton.width - parent.spacing
                        }
                        IconButton {
							id: encryptionKeyCopyButton
    //						text: qsTr("Copy fingerprint")
							icon.source: "image://theme/icon-m-clipboard"
							//                      icon.sourceSize: Qt.size(Theme.iconSizeSmallPlus, Theme.iconSizeSmallPlus)
    //						display: Controls.AbstractButton.IconOnly
    //						flat: !hovered && !encryptionKeyDelegate.hovered
    //						Controls.ToolTip.text: text
							onClicked: {
								Utils.copyToClipboard(model.keyId)
								passiveNotification(qsTr("Fingerprint copied to clipboard"))
							}
						}
					}
				}
			}
		}
	}
	Component.onCompleted: {
		if (!Kaidan.settings.keyAuthenticationPageExplanationVisible) {
			qrCodeScanningArea.scanner.cameraEnabled = true
		}
	}
}
