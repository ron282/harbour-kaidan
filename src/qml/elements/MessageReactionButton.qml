// SPDX-FileCopyrightText: 2022 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a button used for a reaction or for reacting to a message.
 */
Button {
	id: root

	property color primaryColor
	property color accentColor

    height: Theme.itemSizeSmall
	width: smallButtonWidth
	hoverEnabled: true
}
