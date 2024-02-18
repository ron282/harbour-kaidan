// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This page shows two options and an explanation.
 */
ExplainedContentPage {
    property Item primaryArea
    property Item secondaryArea
	property bool explanationInitiallyVisible: true

	primaryButton.onClicked: state = state === "primaryAreaDisplayed" ? "explanationAreaDisplayed" : "primaryAreaDisplayed"
	secondaryButton.onClicked: state = state === "secondaryAreaDisplayed" ? "explanationAreaDisplayed" : "secondaryAreaDisplayed"
	state: explanationInitiallyVisible ? "explanationAreaDisplayed" : "primaryAreaDisplayed"
	states: [
		State {
			name: "explanationAreaDisplayed"
			PropertyChanges { target: explanationArea; visible: true }
			PropertyChanges { target: secondaryArea; visible: false }
		},
		State {
			name: "primaryAreaDisplayed"
			PropertyChanges { target: explanationArea; visible: false }
			PropertyChanges { target: primaryArea; visible: true }
			PropertyChanges { target: secondaryArea; visible: false }
		},
		State {
			name: "secondaryAreaDisplayed"
			PropertyChanges { target: explanationArea; visible: false }
			PropertyChanges { target: primaryArea; visible: false }
			PropertyChanges { target: secondaryArea; visible: true }
		}
	]
	content: Item {
		anchors.fill: parent
		children: [primaryArea, secondaryArea]
	}
}
