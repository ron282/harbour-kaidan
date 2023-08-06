/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

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


	// right: icon for reordering
//	Kirigami.ListItemDragHandle {
//		visible: pinned
//		listItem: root
//		listView: root.listView
//		onMoveRequested: RosterModel.reorderPinnedItem(root.accountJid, root.jid, oldIndex, newIndex)
//	}

	NotificationsMutedWatcher {
		id: mutedWatcher
		jid: root.jid
	}

/*    MouseArea {
        parent: root
        anchors.fill: parent

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                showContextMenu()
            }
            else
            {
                mouse.accepted = false
            }
        }

        onPressAndHold: showContextMenu()
    }
*/
    function showContextMenu() {
        if (contextMenu) {
            root.menu = contextMenu
            contextMenu.item = root
            contextMenu.open(root)
        }
    }
}
