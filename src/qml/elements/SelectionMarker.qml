// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * Used to select an item inside of it.
 */
IconButton {
    id: root
	property bool checked: false

	height: Theme.iconSizeSmall
	width: Theme.iconSizeSmall

	onClicked: {
		checked = !checked
	}

	Rectangle {
		color: Theme.highlightColor
		opacity: 0.8
		radius: width*0.5
		anchors.fill: parent
	}

	icon.source: "image://theme/icon-s-checkmark"
}
