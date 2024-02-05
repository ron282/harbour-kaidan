// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0

DetailsHeader {
	id: root

    property Page sheet

    displayName: AccountManager.displayName
    avatarAction: Button {
        text: qsTr("Change your profile image")
        icon.source: "image://theme/icon-m-edit"
        onClicked: pageStack.push(avatarChangePage)
    }

	Component {
		id: avatarChangePage

		AvatarChangePage {
			Component.onCompleted: {
				if (root.sheet) {
					root.sheet.close()
				}
			}

//			openPage(avatarChangePage)
		}
	}

	function changeDisplayName(newDisplayName) {
		Kaidan.client.vCardManager.changeNicknameRequested(newDisplayName)
	}

	function handleDisplayNameChanged() {
		if (Kaidan.connectionState === Enums.StateConnected) {
			Kaidan.client.vCardManager.clientVCardRequested(root.jid)
		}
	}
}
