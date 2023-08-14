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

import "elements"
import "elements/fields"
import "settings"

/**
 * This page is used for deciding between registration or login.
 */
Page {
    Column {
        anchors.fill: parent
        anchors.leftMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingLarge

        PageHeader {
            title: qsTr("Log in")
        }

        Label {
            text: qsTr("Log in to your XMPP account")
            wrapMode: Text.WordWrap
		}

        // JID field
        JidField {
            id: jidField
            anchors.rightMargin: Theme.horizontalPageMargin
            EnterKey.onClicked: passwordField.focus()
        }

        // password field
        PasswordField {
            id: passwordField

            // Simulate the pressing of the loginButton.
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: {
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
                } else {
                    AccountManager.jid = jidField.text
                    AccountManager.password = passwordField.text
                    AccountManager.host = ""
                    AccountManager.port = ""

                    Kaidan.logIn()
                }
            }
        }
        Component.onCompleted: {
            AccountManager.resetCustomConnectionSettings()
            jidField.forceActiveFocus()
        }
    }
}
