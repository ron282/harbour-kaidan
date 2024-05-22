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
    property ContextMenu contextMenu
    property bool lastMessageIsDraft
    property alias lastMessageDateTime: lastMessageDateTimeText.text
    property string lastMessage
    property string lastMessageSenderId
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
            right: colIcons.left
            top: parent.top
            leftMargin: Theme.paddingMedium;
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
                width: parent.width - Theme.itemSizeMedium - parent.spacing
                font.pixelSize: Theme.fontSizeMedium;
            }
            // last (exchanged/draft) message date/time
            Label {
                id: lastMessageDateTimeText
                text: root.lastMessageDateTime
                width: nameText.width
                visible: text && root.lastMessageDateTime
            }
        }
        Row {
            visible: lastMessageText.text
            anchors.left: parent.left
            anchors.right: parent.right

            Label {
                id: lastMessagePrefix
                visible: text && (lastMessageIsDraft || lastMessageSenderId === root.accountJid)
                textFormat: Text.PlainText
                text: {
                    if (lastMessageIsDraft) {
                        return qsTr("Draft:")
                    } else {
                        // Omit the sender in case of the chat with oneself.
                        if (root.jid == root.accountJid) {
                            return ""
                        }

//                        if (lastMessageSenderId === root.accountJid) {
                            return qsTr("Me:")
//                        }

//                        return qsTr("%1:").arg(root.name)
                    }
                }
                font {
                    pixelSize: Theme.fontSizeSmall
                    weight: Font.Light
                    italic: true
                }
            }

            Label {
                id: lastMessageText
                elide: Text.ElideRight
                width: parent.width - lastMessagePrefix.width - parent.spacing
                maximumLineCount: 1
                text: Utils.removeNewLinesFromString(lastMessage)
                textFormat: Text.PlainText
                font.weight: Font.Light
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    Column {
        id: colIcons
        anchors.right: parent.right
        anchors.top: parent.top
        width: Theme.iconSizeSmallPlus
        // right: icon for muted contact
        // Its size depends on the font's pixel size to be as large as the message counter.
        Icon {
            id: mutedIcon
            source: "image://theme/icon-m-speaker-mute"
            sourceSize.width: parent.width
            sourceSize.height:  parent.width
            visible: notificationsMuted
        }

        // right: icon for pinned chat
        // Its size depends on the font's pixel size to be as large as the message counter.
        Icon {
            id: pinnedIcon
            source: "image://theme/icon-splus-asterisk"
            sourceSize.width:  parent.width
            sourceSize.height:  parent.width
            visible: pinned
        }

        // right: unread message counter
        MessageCounter {
            id: counter
            count: unreadMessages
            muted: notificationsMuted
        }
    }

//    MouseArea {
//        parent: root
//        anchors.fill: parent
//        acceptedButtons: Qt.RightButton

//        onClicked: {
//            if (mouse.button === Qt.RightButton) {
//                showContextMenu()
//            }
//        }

//        onPressAndHold: showContextMenu()
//    }

    onPressAndHold: showContextMenu()

    function showContextMenu() {
        if (contextMenu) {
            root.menu = contextMenu
            contextMenu.item = root
//            contextMenu.open(root)
            openMenu()
        }
    }
}

