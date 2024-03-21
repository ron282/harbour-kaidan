// SPDX-FileCopyrightText: 2016 Marzanna <MRZA-MRZA@users.noreply.github.com>
// SPDX-FileCopyrightText: 2016 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2017 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2018 Allan Nordhøy <epost@anotheragency.no>
// SPDX-FileCopyrightText: 2018 SohnyBohny <sohny.bean@streber24.de>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "fields"
import "../settings"

Column {
	width: parent.width

	// JID field
	JidField {
		id: jidField
//		inputField.onAccepted: loginButton.clicked()
		rightItem: IconButton {
				icon.source: "image://theme/icon-m-setting"
				icon.sourceSize: Qt.size(Theme.iconSizeSmallPlus, Theme.iconSizeSmallPlus)
				onClicked: {
					customConnectionSettings.visible = !customConnectionSettings.visible

					if (jidField.valid && customConnectionSettings.visible) {
						customConnectionSettings.forceActiveFocus()
					} else {
						jidField.forceActiveFocus()
					}
				}
			}
	}

	CustomConnectionSettings {
		id: customConnectionSettings
		confirmationButton: loginButton
		visible: false
	}

	// password field
	PasswordField {
		id: passwordField
//		inputField.onAccepted: loginButton.clicked()
	}

	Button {
		id: loginButton
		text: qsTr("Log in")
		anchors.horizontalCenter: parent.horizontalCenter
		state: Kaidan.connectionState !== Enums.StateDisconnected ? "connecting" : ""
		states: [
			State {
				name: "connecting"
				PropertyChanges {
					target: loginButton
					text: qsTr("Connecting…")
					enabled: false
				}
			}
		]
		// Connect to the server and authenticate by the entered credentials if the JID is valid and a password entered.
		onClicked: {
			// If the JID is invalid, focus its field.
			if (!jidField.text.length > 0) {
				jidField.forceActiveFocus()
				// If the password is invalid, focus its field.
				// This also implies that if the JID field is focused and the password invalid, the password field will be focused instead of immediately trying to connect.
			} else if (!passwordField.text.length > 0) {
				passwordField.forceActiveFocus()
			} else {
				AccountManager.jid = jidField.text
				AccountManager.password = passwordField.text
				AccountManager.host = customConnectionSettings.hostField.text
				AccountManager.port = customConnectionSettings.portField.value

				Kaidan.logIn()
			}
		}
	}

	Component.onCompleted: AccountManager.resetCustomConnectionSettings()

	function initialize() {
		if (jidField.valid) {
			passwordField.forceActiveFocus()
		} else if (jidField.text) {
			// This is used after a web registration when only the provider is known.
			// Prepend "@" to the server JID and move the cursor to the field's beginning.
			// That way, the username can be directly entered.
			jidField.text = "@" + jidField.text
			jidField.forceActiveFocus()
			jidField.inputField.cursorPosition = 0
		} else {
			jidField.forceActiveFocus()
//			jidField.invalidHintMayBeShown = false
			jidField.toggleHintForInvalidText()
		}
	}

	function reset() {
		jidField.invalidHintMayBeShown = false
		jidField.toggleHintForInvalidText()

		passwordField.invalidHintMayBeShown = false
		passwordField.toggleHintForInvalidText()
	}
}
