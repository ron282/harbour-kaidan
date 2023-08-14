// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2022 Bhavy Airi <airiragahv@gmail.com>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

UserListItem {
	id: root

	property ListView listView
    property ContextMenu contextMenu
    property bool lastMessageIsDraft
	property string lastMessage
	property int unreadMessages
	property bool pinned
    property bool notificationsMuted

	isSelected: {
        return MessageModel.currentAccountJid === accountJid &&
               MessageModel.currentChatJid === jid
	}

	// middle
    Column {
        spacing: Theme.paddingLarge
        anchors {
            left: avatar.right;
            right: parent.right
            top: parent.top
            margins: Theme.paddingMedium;
        }

		// name
        Row {
            width: parent.width
            Label  {
                id: nameText
                text: name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                maximumLineCount: 1
                width: parent.width - mutedIcon.width - pinnedIcon.width - counter.width
                font.pixelSize: Theme.fontSizeMedium;
            }
            // right: icon for muted contact
            // Its size depends on the font's pixel size to be as large as the message counter.
            Icon {
                id: mutedIcon
                source: "image://theme/icon-m-speaker-mute"
                width: Theme.iconSizeSmall
                height: width
                visible: mutedWatcher.muted
            }

            // right: icon for pinned chat
            // Its size depends on the font's pixel size to be as large as the message counter.
            Icon {
                id: pinnedIcon
                source: "image://theme/icon-m-asterisk"
                width: Theme.iconSizeSmall
                height: width
                visible: pinned
            }

            // right: unread message counter
            MessageCounter {
                id: counter
                count: unreadMessages
                muted: mutedWatcher.muted
            }
        }
		// last message or error status message if available, otherwise not visible
        Row {
            id: layout
			visible: lastMessageText.text
            width: parent.width

            Label {
				id: draft
				visible: lastMessageIsDraft
                font.pixelSize: Theme.fontSizeSmall
				textFormat: Text.PlainText
				text: qsTr("Draft:")
			}

            Label {
				id: lastMessageText
                width: layout.width - draft.width - layout.spacing
				elide: Text.ElideRight
				maximumLineCount: 1
				text: Utils.removeNewLinesFromString(lastMessage)
				textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeSmall
            }
		}
	}

    function showContextMenu() {
        if (contextMenu) {
            root.menu = contextMenu
            contextMenu.item = root
            contextMenu.open(root)
        }
    }
}

