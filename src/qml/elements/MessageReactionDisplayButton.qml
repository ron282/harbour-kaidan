// SPDX-FileCopyrightText: 2022 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a button for displaying an emoji in reaction to a message.
 */
MessageReactionButton {
	id: root

	property string description
	property bool ownReactionIncluded: true
	property int deliveryState
	property bool isOwnMessage

	primaryColor: {
		if (ownReactionIncluded) {
			if (deliveryState === MessageReactionDeliveryState.PendingAddition ||
				deliveryState === MessageReactionDeliveryState.PendingRemovalAfterSent ||
				deliveryState === MessageReactionDeliveryState.PendingRemovalAfterDelivered) {
				return Kirigami.Theme.neutralBackgroundColor
			} else if (deliveryState === MessageReactionDeliveryState.ErrorOnAddition ||
				deliveryState === MessageReactionDeliveryState.ErrorOnRemovalAfterSent ||
				deliveryState === MessageReactionDeliveryState.ErrorOnRemovalAfterDelivered) {
				return Kirigami.Theme.negativeBackgroundColor
			}

			return Kirigami.Theme.positiveBackgroundColor
		}

		return isOwnMessage ? primaryBackgroundColor : secondaryBackgroundColor
	}
    text: root.text
}
