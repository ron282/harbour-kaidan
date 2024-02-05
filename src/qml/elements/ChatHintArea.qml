// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is an area used for displaying hints and corresponding buttons on the chat page.
 *
 * It is opened by increasing its height and closed by decreasing it again.
 */
Rectangle {
	id: root

	property int index
	property string text
	property var buttons
	property bool loading
	property string loadingDescription

	width: ListView.view.width
	height: enabled ? contentArea.height : 0
	enabled: false
	clip: true
	color: primaryBackgroundColor
	ListView.delayRemove: true
	onLoadingChanged: loading ? loadingStackArea.showLoadingView() : loadingStackArea.hideLoadingView()
	onHeightChanged: {
		// Ensure the deletion of this item after the removal animation of decreasing its height.
		// When this item is removed from the model (i.e., it has the index -1), it is set to be
		// finally removed from the user interface as soon as it is completely collapsed.
		if (index === -1 && height === 0) {
            SilicaListView.delayRemove = false
		}
	}

	Behavior on height {
		SmoothedAnimation {
			velocity: 550
		}
	}

    Column {
		id: contentArea
		anchors.left: root.left
		anchors.right: root.right

		// top: colored separator
		Rectangle {
			height: 3
			color: Kirigami.Theme.highlightColor
            anchors.left: parent.left
            anchors.right: parent.right
        }

		// middle: chat hint
        Column {
            anchors.margins: Theme.paddingLarge

			LoadingStackArea {
				id: loadingStackArea
				loadingArea.background.visible: false
				loadingArea.description: root.loadingDescription

                Column {
					visible: root.text

					CenteredAdaptiveText {
						id: hintText
						text: root.text
					}
				}

                Row {
					visible: root.buttons.length
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.buttonWidthLarge * root.buttons.length + spacing

                    SilicaGridView {
						id: buttonArea
						model: root.buttons
						delegate: CenteredAdaptiveButton {
							text: modelData.text
							onClicked: ChatHintModel.handleButtonClicked(root.index, modelData.type)
						}
					}
				}
			}
		}

		// bottom: colored separator
        Separator {
		}
	}
}
