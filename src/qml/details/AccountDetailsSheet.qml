// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0
import QtQml 2.0

DetailsSheet {
	id: root

	AccountDetailsHeader {
		sheet: root
		jid: AccountManager.jid
	}

	AccountDetailsContent {
		sheet: root
		jid: AccountManager.jid
		width: parent.width
	}

    Connections {
		target: Kaidan

		// Close this sheet when the account is removed.
		function onCredentialsNeeded() {
			root.close()
		}

		// Close this sheet when the chat with oneself is added via it.
		function onOpenChatPageRequested(accountJid, chatJid) {
			root.close()
		}
	}
}
