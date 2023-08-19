// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0

DetailsPage {
	id: root

	AccountDetailsHeader {
        id: header
		jid: AccountManager.jid
	}

    SilicaFlickable {
        anchors.top: header.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        contentHeight: Screen.height*2
        contentWidth: parent.width
        clip: true

        AccountDetailsContent {
            jid: AccountManager.jid
            width: parent.width
        }
    }
}
