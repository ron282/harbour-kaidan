// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a button for opening the details of all emojis in reaction to a message.
 */
MessageReactionButton {
	id: root

	property string messageId
	property var detailedReactions
	property var ownDetailedReactions
	property bool isOwnMessage
	property MessageReactionDetailsSheet detailsSheet

	primaryColor: isOwnMessage ? primaryBackgroundColor : secondaryBackgroundColor
    contentItem: Icon {
        source: "image://theme/icon-m-add"
	}
	onClicked: {
		detailsSheet.messageId = messageId
		detailsSheet.isOwnMessage = isOwnMessage
		detailsSheet.detailedReactions = detailedReactions
		detailsSheet.ownDetailedReactions = ownDetailedReactions
		detailsSheet.open()
	}
	onDetailedReactionsChanged: {
		detailsSheet.detailedReactions = detailedReactions
	}
	onOwnDetailedReactionsChanged: {
		detailsSheet.ownDetailedReactions = ownDetailedReactions
	}
}
