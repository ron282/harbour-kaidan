// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import "../elements/fields"

/**
 * This view is the base for views containing fields.
 */
BackgroundItem {

    property alias descriptionText : fieldDesc.text
    property alias imageSource: fieldIcon.source

    anchors.fill: parent

	/**
	 * Disallows the swiping and shows or hides the hint for invalid text input.
	 */
	function handleInvalidText() {
		swipeView.interactive = valid
		field.toggleHintForInvalidText()
	}

	function forceActiveFocus() {
		field.forceActiveFocus()
	}

    Image {
        id: fieldIcon
        anchors.top: parent.top
        anchors.left: parent.left
    }

    TextArea {
        id: fieldDesc
        anchors.left: fieldIcon.right
        anchors.top: parent.top
    }

    ViewPlaceholder {
        id: contentArea
        width: parent.width
        anchors.top: fieldDesc.bottom
        anchors.bottom: parent.bottom
    }

//	Controls.SwipeView.onIsCurrentItemChanged: {
//		if (Controls.SwipeView.isCurrentItem) {
//			if (!field.focus) {
//				forceActiveFocus()
//			}
//		}
//	}

//	Component.onCompleted: {
//		if (Controls.SwipeView.isCurrentItem) {
//			forceActiveFocus()
//		}
//	}
}
