/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "elements"
import "elements/fields"
import "settings"

/**
 * This page is used for deciding between registration or login.
 */
Page {
    PageHeader {
        title: qsTr("Log in")
    }
    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Theme.paddingLarge

        Label {
			text: qsTr("Log in to your XMPP account")
			wrapMode: Text.WordWrap
		}

        // JID field
        JidField {
            id: jidField

            EnterKey.onClicked: passwordField.focus()

/*				inputField.rightActions: [
                Kirigami.Action {
                    icon.name: "preferences-system-symbolic"
                    text: qsTr("Connection settings")
                    onTriggered: {
                        customConnectionSettings.visible = !customConnectionSettings.visible

                        if (jidField.valid && customConnectionSettings.visible)
                            customConnectionSettings.forceActiveFocus()
                        else
                            jidField.forceActiveFocus()
                    }
                }
            ]
*/
          }

//			CustomConnectionSettings {
//				id: customConnectionSettings
//				confirmationButton: loginButton
//				visible: false
//			}

			// password field
			PasswordField {
				id: passwordField

				// Simulate the pressing of the loginButton.
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if( acceptableInput)
                        loginButton.clicked()
				}
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
					if (!jidField.valid) {
						jidField.forceActiveFocus()
					// If the password is invalid, focus its field.
					// This also implies that if the JID field is focused and the password invalid, the password field will be focused instead of immediately trying to connect.
					} else if (!passwordField.valid) {
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
        Component.onCompleted: {
            AccountManager.resetCustomConnectionSettings()
            jidField.forceActiveFocus()
        }
    }

	/*
	 * Fills the JID field with "@" followed by a domain and moves the cursor to
	 * the beginning so that the username can be directly entered.
	 *
	 * \param domain domain being inserted into the JID field
	 */
	function prefillJidDomain(domain) {
		jidField.text = "@" + domain
		jidField.inputField.cursorPosition = 0
	}
}
