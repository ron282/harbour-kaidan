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

    property SilicaListView listView
    property alias contextMenu: root.menu
    property bool lastMessageIsDraft
    property alias lastMessageDateTime: lastMessageDateTimeText.text
    property string lastMessage
	property int unreadMessages
	property bool pinned
    property bool notificationsMuted

	isSelected: {
        return false &&
               MessageModel.currentAccountJid === accountJid &&
               MessageModel.currentChatJid === jid
	}

	// middle
    Column {
        spacing: Theme.paddingSmall
        anchors {
            left: avatar.right;
            right: parent.right
            top: parent.top
            margins: Theme.paddingMedium;
        }

		// name
        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            Label  {
                id: nameText
                text: root.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                maximumLineCount: 1
                width: parent.width - mutedIcon.width - pinnedIcon.width - counter.width
                font.pixelSize: Theme.fontSizeMedium;
            }
            // last (exchanged/draft) message date/time
            Label {
                id: lastMessageDateTimeText
                text: root.lastMessageDateTime
                visible: text
            }
        }
        Row {
            visible: lastMessageText.text
            anchors.left: parent.left
            anchors.right: parent.right

            Label {
                id: draft
                visible: lastMessageIsDraft
                textFormat: Text.PlainText
                text: qsTr("Draft:")
                font {
                    weight: Font.Light
                    italic: true
                }
            }

            Label {
                id: lastMessageText
                elide: Text.ElideRight
                width: parent.width - draft.width
                maximumLineCount: 1
                text: Utils.removeNewLinesFromString(lastMessage)
                textFormat: Text.PlainText
                font.weight: Font.Light
            }
        }
    }

    Column {
        anchors.right: parent.right
        anchors.top: parent.top
        width: Theme.iconSizeMedium
        // right: icon for muted contact
        // Its size depends on the font's pixel size to be as large as the message counter.
        Icon {
            id: mutedIcon
            source: "image://theme/icon-m-speaker-mute"
            width: Theme.iconSizeSmall
            height: width
            visible: notificationsMuted
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
            muted: notificationsMuted
        }
    }

 /*   MouseArea {
        parent: root
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                showContextMenu()
            }
        }

        onPressAndHold: showContextMenu()
    }
*/
    function showContextMenu() {
        console.log("[RosterListItem.qml] showContextMenu")
        if (contextMenu) {
            root.menu = contextMenu
            contextMenu.item = root
            contextMenu.open(root)
        }
    }
}

