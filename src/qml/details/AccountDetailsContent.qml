// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import QtQuick.Controls 2.14 as Controls
// import org.kde.kirigami 2.19 as Kirigami
// import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import im.kaidan.kaidan 1.0

import "../elements"
import "../elements/fields"
import "../settings"

DetailsContent {
	id: root
	encryptionArea: Column {
		spacing: 0

		Component.onCompleted: {
			// Retrieve the own devices if they are not loaded yet on a mobile device.
			if (!root.sheet && MessageModel.currentAccountJid != root.jid) {
				Kaidan.client.omemoManager.initializeChatRequested(root.jid)
			}

			passwordVerificationField.initialize()
			passwordField.initialize()
		}
		Connections {
			target: root.sheet

			function onSheetOpenChanged() {
				if (root.sheet.sheetOpen) {
					// Retrieve the own devices if they are not loaded yet on a desktop device.
					if (MessageModel.currentAccountJid != root.jid) {
						Kaidan.client.omemoManager.initializeChatRequested(root.jid)
					}

					passwordVerificationField.initialize()
					passwordField.initialize()
					passwordChangeErrorMessage.visible = false
					connectionSettingsErrorMessage.visible = false
				}
			}
		}

		OmemoWatcher {
			id: omemoWatcher
			jid: root.jid
		}

        SectionHeader {
            text: qsTr("Encryption")
		}

        TextSwitch {
            text: qsTr("OMEMO 0")
            //FIXME description: qsTr("End-to-end encryption with OMEMO 0 ensures that nobody else than you and your chat partners can read or modify the data you exchange.")
            checked: Kaidan.settings.encryption === Encryption.Omemo0
			// The switch is toggled by setting the user's preference on using encryption.
			// Note that 'checked' has already the value after the button is clicked.
			onClicked: {
				if (checked) {
                    Kaidan.settings.encryption = Encryption.Omemo0
                    RosterModel.setItemEncryption(root.jid, Encryption.Omemo0)
				} else {
					Kaidan.settings.encryption = Encryption.NoEncryption
					RosterModel.setItemEncryption(root.jid, Encryption.NoEncryption)
				}
			}
		}

        Button {
			text: {
				if (!omemoWatcher.usableOmemoDevices.length) {
					if (omemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
					} else if (ownResourcesWatcher.resourcesCount > 1) {
                        return qsTr("<b>Your</b> other devices don't use OMEMO 0")
					}
				} else if (omemoWatcher.authenticatableOmemoDevices.length) {
					if (omemoWatcher.authenticatableOmemoDevices.length === omemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
					}

					return qsTr("Scan the QR codes of <b>your</b> devices for maximum security")
				}

				return ""
			}
			icon.source: {
				if (!omemoWatcher.usableOmemoDevices.length) {
					if (omemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-device-lock"
					} else if (ownResourcesWatcher.resourcesCount > 1) {
                        return "image://theme/icon-m-warning"
					}
				} else if (omemoWatcher.authenticatableOmemoDevices.length) {
					if (omemoWatcher.authenticatableOmemoDevices.length === omemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-warning"
					}

                    return "image://theme/icon-m-device-lock"
				}

				return ""
			}
			visible: text
			enabled: omemoWatcher.authenticatableOmemoDevices.length
			onClicked: pageStack.layers.push(qrCodePage, { isForOwnDevices: true })

			UserResourcesWatcher {
				id: ownResourcesWatcher
				jid: root.jid
			}
		}
	}

	RosterAddContactSheet {
		id: contactAdditionSheet
	}

    SilicaFlickable {
		id: providerArea
		width: parent.width
		visible: providerUrl  || chatSupportList.length || groupChatSupportList.length

		readonly property string providerUrl: {
			const domain = root.jid.split('@')[1]
			const provider = providerListModel.provider(domain)

			return providerListModel.chooseWebsite(provider.websites)
		}

		readonly property var chatSupportList: providerListModel.providerFromBareJid(root.jid).chatSupport
		readonly property var groupChatSupportList: providerListModel.providerFromBareJid(root.jid).groupChatSupport

         Column {
			spacing: 0

			ProviderListModel {
				id: providerListModel
			}

			ChatSupportSheet {
				id: chatSupportSheet
				chatSupportList: providerArea.chatSupportList
			}

            SectionHeader {
                text: qsTr("Provider")
			}

            Button {
				text: qsTr("Visit website")
                //FIXME description: qsTr("Open your provider's website in a web browser")
				visible: providerArea.providerUrl
				onClicked: Qt.openUrlExternally(providerArea.providerUrl)
			}

            Button {
				text: qsTr("Copy website address")
                //FIXME description: qsTr("Copy your provider's web address to the clipboard")
				visible: providerArea.providerUrl
				onClicked: {
					Utils.copyToClipboard(providerArea.providerUrl)
					passiveNotification(qsTr("Website address copied to clipboard"))
				}
			}

            Button {
				text: qsTr("Open support chat")
                //FIXME description: qsTr("Start chat with your provider's support contact")
				visible: providerArea.chatSupportList.length > 0
				onClicked: {
					if (providerArea.chatSupportList.length === 1) {
						if (!contactAdditionSheet.sheetOpen) {
							contactAdditionSheet.jid = providerArea.chatSupportList[0]
							contactAdditionSheet.nickname = qsTr("Support")
							root.sheet.close()
							contactAdditionSheet.open()
						}
					} else if (!chatSupportSheet.sheetOpen) {
						root.sheet.close()
						chatSupportSheet.open()
					}
				}
			}

            Button {
				text: qsTr("Open support group")
                //FIXME description: qsTr("Join your provider's public support group")
				visible: providerArea.groupChatSupportList.length > 0
				onClicked: {
					if (providerArea.groupChatSupportList.length === 1) {
						Qt.openUrlExternally(Utils.groupChatUri(providerArea.groupChatSupportList[0]))
					} else {
						chatSupportSheet.isGroupChatSupportSheet = true

						if (!chatSupportSheet.sheetOpen) {
							chatSupportSheet.open()
						}
					}
				}
			}
		}
	}

    SilicaFlickable {
		visible: Kaidan.serverFeaturesCache.inBandRegistrationSupported
		width: parent.width

         Column {
			spacing: 0

            SectionHeader {
                text: qsTr("Password Change")
			}

            Label {
				text: qsTr("Change your password. You need to enter the new password on all your other devices!")
			}

            BackgroundItem {
                // background: Item {}
                 Column {
                    TextField {
                        text: qsTr("Current password")
                    }

					PasswordField {
						id: passwordVerificationField
						placeholderText: "Enter your current password"
                        // invalidHintText: qsTr("Enter correct password")
						visible: Kaidan.settings.passwordVisibility !== Kaidan.PasswordVisible
						enabled: !passwordBusyIndicator.visible
                        anchors.rightMargin: passwordChangeConfirmationButton.Layout.preferredWidth + passwordButtonFieldArea.spacing
						onTextChanged: {
							valid = text === AccountManager.password
							toggleHintForInvalidText()
						}
                        EnterKey.onClicked: passwordChangeConfirmationButton.clicked()

						function initialize() {
							showPassword = false
							invalidHintMayBeShown = false
							text = ""
						}
					}

					Row {
						id: passwordButtonFieldArea

                        TextField {
                            text: passwordVerificationField.visible ? qStr("New password") : qStr("Password")
                        }

                        PasswordField {
							id: passwordField
							placeholderText: "Enter your new password"
                            //invalidHintText: qsTr("Enter different password to change it")
                            //invalidHintMayBeShown: true
							enabled: !passwordBusyIndicator.visible
							onTextChanged: {
								valid = credentialsValidator.isPasswordValid(text) && text !== AccountManager.password
								toggleHintForInvalidText()
							}
                            EnterKey.onClicked: passwordChangeConfirmationButton.clicked()

							function initialize() {
								showPassword = false
								text = passwordVerificationField.visible ? "" : AccountManager.password

								// Avoid showing a hint on initial setting.
								invalidHint.visible = false
							}
						}

						Button {
							id: passwordChangeConfirmationButton
                            //FIXME Controls.ToolTip.text: qsTr("Change password")
                            icon.source: "image://theme/icon-m-enter-accept"
							visible: !passwordBusyIndicator.visible
                            //FIXME flat: true
                            //FIXME Layout.preferredWidth: // Layout.preferredHeight
                            // //FIXME Layout.preferredHeight: passwordField.inputField.implicitHeight
                            // Layout.alignment: passwordField.invalidHint.visible ? Qt.AlignVCenter : Qt.AlignBottom
							onHoveredChanged: {
								if (hovered) {
									flat = false
								} else {
									flat = true
								}
							}
							onClicked: {
								if (passwordVerificationField.visible && !passwordVerificationField.valid) {
									passwordVerificationField.forceActiveFocus()
								} else if (!passwordField.valid) {
									passwordField.forceActiveFocus()
									passwordField.toggleHintForInvalidText()
								} else {
									passwordBusyIndicator.visible = true
									Kaidan.client.registrationManager.changePasswordRequested(passwordField.text)
								}
							}
						}

                        BusyIndicator {
							id: passwordBusyIndicator
							visible: false
                            //FIXME Layout.preferredWidth: passwordChangeConfirmationButton.Layout.preferredWidth
                            // //FIXME Layout.preferredHeight: Layout.preferredWidth
                            // Layout.alignment: passwordChangeConfirmationButton.Layout.alignment
						}
					}

                    Label {
						id: passwordChangeErrorMessage
						visible: false
						font.bold: true
						wrapMode: Text.WordWrap
						padding: 10
						width: parent.width
                        Rectangle {
							color: Kirigami.Theme.negativeBackgroundColor
							radius: roundedCornersRadius
						}
					}

					Connections {
						target: Kaidan

						function onPasswordChangeFailed(errorMessage) {
							passwordBusyIndicator.visible = false
							passwordChangeErrorMessage.visible = true
							passwordChangeErrorMessage.text = qsTr("Failed to change password: %1").arg(errorMessage)
						}

						function onPasswordChangeSucceeded() {
							passwordBusyIndicator.visible = false
							passwordChangeErrorMessage.visible = false
							passiveNotification(qsTr("Password changed successfully"))
						}
					}
				}
			}
		}
	}

    SilicaFlickable {
		visible: Kaidan.settings.passwordVisibility !== Kaidan.PasswordInvisible
		width: parent.width

         Column {
			spacing: 0

            SectionHeader {
                text: qsTr("Password Security")
			}

            Label {
				text: qsTr("Configure this device to not expose your password for changing it or switching to another device. If you want to change your password or use your account on another device later, <b>consider storing the password somewhere else. This cannot be undone!</b>")
			}

            Button {
				text: qsTr("Don't show password as text")
				visible: Kaidan.settings.passwordVisibility === Kaidan.PasswordVisible
                //FIXME description: qsTr("Allow to add additional devices using the login QR code but never show the password")
                icon.source: "image://theme/icon-splus-hide-password"
				onClicked: {
					Kaidan.settings.passwordVisibility = Kaidan.PasswordVisibleQrOnly
					passwordField.initialize()
				}
			}

            Button {
				text: qsTr("Don't expose password in any way")
				visible: Kaidan.settings.passwordVisibility !== Kaidan.PasswordInvisible
                //FIXME description: qsTr("Neither allow to add additional devices using the login QR code nor show the password")
				icon.source: "security-high-symbolic"
				onClicked: {
					const oldPasswordVisibility = Kaidan.settings.passwordVisibility
					Kaidan.settings.passwordVisibility = Kaidan.PasswordInvisible

					// Do not initialize passwordField when the password is already hidden.
					if (oldPasswordVisibility === Kaidan.PasswordVisible) {
						passwordField.initialize()
					}
				}
			}
		}
	}

    SilicaFlickable {
		width: parent.width

         Column {
			spacing: 0

            SectionHeader {
                text: qsTr("Connection")
			}

            Label {
				text: qsTr("Configure the hostname and port to connect to (empty fields for default values)")
			}

            BackgroundItem {
                // background: Item {}
                 Column {
					id: connectionSettings

					Row {
						CustomConnectionSettings {
							id: customConnectionSettings
							confirmationButton: connectionSettingsConfirmationButton
						}

						Button {
							id: connectionSettingsConfirmationButton
                            //FIXME Controls.ToolTip.text: qsTr("Change connection settings")
							icon.source: "emblem-ok-symbolic"
							visible: !connectionSettingsBusyIndicator.visible
                            //FIXME flat: true
                            //FIXME Layout.preferredWidth: // Layout.preferredHeight
                            // //FIXME Layout.preferredHeight: customConnectionSettings.portField.implicitHeight
                            // Layout.alignment: Qt.AlignBottom
							onHoveredChanged: {
								if (hovered) {
									flat = false
								} else {
									flat = true
								}
							}
							onClicked: {
								if (customConnectionSettings.hostField.text === AccountManager.host && customConnectionSettings.portField.value === AccountManager.port) {
									connectionSettingsErrorMessage.text = qsTr("Enter different connection settings to change them")
									connectionSettingsErrorMessage.visible = true
								} else {
									connectionSettingsBusyIndicator.visible = true

									// Reset the error message in case of previous button clicking without changed entered settings.
									if (Kaidan.connectionError === ClientWorker.NoError) {
										connectionSettingsErrorMessage.visible = false
									}

									if (Kaidan.connectionState === Enums.StateDisconnected) {
										connectionSettings.logIn()
									} else {
										Kaidan.logOut()
									}
								}
							}
						}

                        BusyIndicator {
							id: connectionSettingsBusyIndicator
							visible: false
                            //FIXME Layout.preferredWidth: connectionSettingsConfirmationButton.Layout.preferredWidth
                            // //FIXME Layout.preferredHeight: Layout.preferredWidth
                            // Layout.alignment: connectionSettingsConfirmationButton.Layout.alignment
						}
					}

                    Label {
						id: connectionSettingsErrorMessage
						visible: false
						font.bold: true
						wrapMode: Text.WordWrap
						padding: 10
						width: parent.width
                        Rectangle {
							color: Kirigami.Theme.negativeBackgroundColor
							radius: roundedCornersRadius
						}
					}

					Connections {
						target: Kaidan

						function onConnectionErrorChanged() {
							// Skip connection error changes not invoked via connectionSettings by checking whether connectionSettingsBusyIndicator is visible.
							if (Kaidan.connectionError === ClientWorker.NoError) {
								connectionSettingsErrorMessage.visible = false
							} else {
								connectionSettingsErrorMessage.visible = true
								connectionSettingsErrorMessage.text = qsTr("Connection settings could not be changed: %1").arg(Utils.connectionErrorMessage(Kaidan.connectionError))
							}
						}

						function onConnectionStateChanged() {
							// Skip connection state changes not invoked via connectionSettings by checking whether connectionSettingsBusyIndicator is visible.
							if (connectionSettingsBusyIndicator.visible) {
								if (Kaidan.connectionState === Enums.StateDisconnected) {
									if (Kaidan.connectionError === ClientWorker.NoError) {
										connectionSettings.logIn()
									} else {
										connectionSettingsBusyIndicator.visible = false
									}
								} else if (Kaidan.connectionState === Enums.StateConnected) {
									connectionSettingsBusyIndicator.visible = false
									passiveNotification(qsTr("Connection settings changed"))
								}
							}
						}
					}

					function logIn() {
						AccountManager.host = customConnectionSettings.hostField.text
						AccountManager.port = customConnectionSettings.portField.value
						Kaidan.logIn()
					}
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
					text: qsTr("Remove from Kaidan")
                    //FIXME description: qsTr("Remove account from this app. Back up your credentials and chat history if needed!")
                    icon.source: "image://theme/icon-s-edit"
                    // checkable: true
                    onCheckedChanged: contactRemovalCorfirmationButton.visible = !contactRemovalCorfirmationButton.visible
				}

                Button {
					id: contactRemovalCorfirmationButton
					text: qsTr("Confirm")
					visible: false
                    anchors.leftMargin: Kirigami.Units.largeSpacing * 6
					onClicked: {
						visible = false
						removalButton.enabled = false
						Kaidan.deleteAccountFromClient()
					}
				}
			}

			Column {
				spacing: 0

                IconTextSwitch {
					id: deletionButton
					text: qsTr("Delete completely")
                    //FIXME description: qsTr("Delete account from provider. You will not be able to use your account again!")
                    icon.source: "image://theme/icon-s-edit"
                    // checkable: true
                    onCheckedChanged: contactDeletionCorfirmationButton.visible = !contactDeletionCorfirmationButton.visible
				}

                Button {
					id: contactDeletionCorfirmationButton
					text: qsTr("Confirm")
					visible: false
                    anchors.leftMargin: Kirigami.Units.largeSpacing * 6
					onClicked: {
						visible = false
						removalButton.enabled = false
						Kaidan.deleteAccountFromClientAndServer()
					}
				}
			}
		}
	}
}
