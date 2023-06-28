// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

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
}
