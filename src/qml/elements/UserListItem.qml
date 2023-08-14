// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

ListItem {
	id: root

//	default property alias __data: content.data
	property alias avatar: avatar

	property string accountJid
	property string jid
	property string name
	property bool isSelected: false
    height: Theme.iconSizeExtraLarge

    // left border: presence
    Rectangle {
        id: presenceIndicator
        width: Theme.paddingSmall
        height: parent.height
        color: userPresence.availabilityColor
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium

        UserPresenceWatcher {
            id: userPresence
            jid: root.jid
        }
    }

    // left: avatar
    Avatar {
        id: avatar
        jid: root.jid
        name: root.name
        anchors.left: presenceIndicator.right
        anchors.top: presenceIndicator.top
    }
}
