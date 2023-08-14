// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

Dialog {
	id: root

	property alias jid: content.jid
	property alias name: content.name

    DialogHeader {
        title: qsTr("Add contact")
    }

	onOpened: content.jidField.forceActiveFocus()

	ContactAdditionContent {
		id: content
		jidField.inputField.onActiveFocusChanged: {
			// The active focus is taken by another item after opening.
			// Thus, it must be forced again.
			if (!jidField.inputField.activeFocus && !nameField.inputField.activeFocus && !messageField.activeFocus) {
				jidField.forceActiveFocus()
				jidField.invalidHintMayBeShown = false
			} else {
				jidField.invalidHintMayBeShown = true
			}
		}
	}

	Connections {
		target: Kaidan

		function onOpenChatPageRequested(accountJid, chatJid) {
			root.close()
		}
	}
}
