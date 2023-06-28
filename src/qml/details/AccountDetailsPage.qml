// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

DetailsPage {
	id: root

	AccountDetailsHeader {
		jid: AccountManager.jid
	}

	AccountDetailsContent {
		jid: AccountManager.jid
		width: parent.width
	}
}
