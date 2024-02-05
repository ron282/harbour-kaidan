// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0
import QtQuick 2.2
//import QtQuick.Layouts 1.14

import im.kaidan.kaidan 1.0

DetailsSheet {
	id: root

    property string accountJid
    property string jid
//  required property string accountJid
//	required property string jid

    ContactDetailsHeader {
        id: header
        jid: root.jid
    }

	ContactDetailsContent {
		sheet: root
		accountJid: root.accountJid
		jid: root.jid
//		Layout.fillWidth: true
	}

	Connections {
		target: Kaidan

		// Close this sheet when the contact is removed.
		function onCloseChatPageRequested() {
			root.close()
		}
	}
}
