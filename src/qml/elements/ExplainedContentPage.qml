// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbblp@protonmail.ch>
// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This page is the base for pages with content needing an explanation.
 *
 * It consists of a centered content area and an overlay containing an explanation area with a background and two buttons.
 */
Page {
    anchors.leftMargin: 0
    anchors.rightMargin: 0
    anchors.topMargin: 0
    anchors.bottomMargin: 0

    property alias title: header.title

    /**
	 * area containing the explanation displayed while the content is not displayed
	 */
	property alias explanationArea: explanationArea

	/**
	 * explanation within the explanation area
	 */
	property alias explanation: explanationArea.data

	/**
	 * content displayed while the explanation is not displayed
	 */
	property alias content: contentArea.data

	/**
	 * button for a primary action
	 */
	property alias primaryButton: primaryButton

	/**
	 * button for a secondary action
	 */
	property alias secondaryButton: secondaryButton

	/**
	 * true to have a margin between the content and the window's border, otherwise false
	 */
	property bool useMarginsForContent: true

	Item {
		id: contentArea
		anchors.fill: parent
		anchors.margins: useMarginsForContent ? 20 : 0
		anchors.bottomMargin: useMarginsForContent ? parent.height - buttonArea.y : 0
	}

	// background of overlay
	Rectangle {
		z: 1
		anchors.fill: overlay
		anchors.margins: -8
		radius: roundedCornersRadius
        color: Theme.backgroundColor
		opacity: 0.90
		visible: explanationArea.visible
	}

    Column {
		id: overlay
		z: 2
		anchors.margins: 18
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom

        PageHeader {
            id: header
        }

        Grid {
			id: explanationArea
            width: parent.width
            height: parent.height
		}

        Column {
			id: buttonArea
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.buttonWidthLarge

			CenteredAdaptiveHighlightedButton {
				id: primaryButton
			}

			CenteredAdaptiveButton {
				id: secondaryButton
			}
		}
	}
}
