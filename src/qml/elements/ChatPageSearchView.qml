// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2022 Tibor Csötönyi <dev@taibsu.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
//import QtQuick 2.2
//import Sailfish.Silica 1.0
//// import QtQuick.Controls 2.14 as Controls
//// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

/**
 * This is a view for searching chat messages.
 */
Item {
	height: active ? searchField.height + 2 * Kirigami.Units.largeSpacing : 0
	clip: true
	visible: height != 0
	property bool active: false
    property alias searchFieldBusyIndicator: busyIndicator

	Behavior on height {
		SmoothedAnimation {
			velocity: 200
		}
	}

	// Background of the message search bar

	// Search field and its corresponding buttons
	Row {
		// Anchoring like this binds it to the top of the chat page.
		// It makes it look like the search bar slides down from behind of the upper element.
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
        anchors.margins: Theme.paddingLarge

        Button {
			text: qsTr("Close message search bar")
            icon.source: "image://theme/icon-m-close"
			onClicked: searchBar.close()
			//FIXME display: Controls.Button.IconOnly
			//FIXME flat: true
		}

        SearchField {
			id: searchField
			width: parent.width
            //focusSequence: ""
			onVisibleChanged: text = ""
			onTextChanged: searchUpwardsFromBottom()
            //FIXME onAccepted: searchFromCurrentIndex(true)
			Keys.onUpPressed: searchFromCurrentIndex(true)
			Keys.onDownPressed: searchFromCurrentIndex(false)
			Keys.onEscapePressed: close()
            //FIXME autoAccept: false

			BusyIndicator {
                id: busyIndicator

				anchors {
					right: parent.right
					rightMargin: height / 2
					top: parent.top
					bottom: parent.bottom
				}

				running: false
			}
		}

        Button {
			text: qsTr("Search up")
            icon.source: "image://theme/icon-m-page-up"
			//FIXME display: Controls.Button.IconOnly
			//FIXME flat: true
			onClicked: {
				searchFromCurrentIndex(true)
				searchField.forceActiveFocus()
			}
		}

        Button {
			text: qsTr("Search down")
            icon.source: "image://theme/icon-m-page-down"
			//FIXME display: Controls.Button.IconOnly
			//FIXME flat: true
			onClicked: {
				searchFromCurrentIndex(false)
				searchField.forceActiveFocus()
			}
		}
	}

	/**
	 * Shows the search bar and focuses the search field.
	 */
	function open() {
		searchField.forceActiveFocus()
		active = true
	}

	/**
	 * Hides the search bar and resets the last search result.
	 */
	function close() {
		messageListView.currentIndex = -1
		active = false
	}

	/**
	 * Searches upwards for a message containing the entered text in the search field starting from the current index of the message list view.
	 */
	function searchUpwardsFromBottom() {
		search(true, 0)
	}

	/**
	 * Searches for a message containing the entered text in the search field starting from the current index of the message list view.
	 *
	 * The searchField is automatically focused again on desktop devices if it lost focus (e.g., after clicking a button).
	 *
	 * @param searchUpwards true for searching upwards or false for searching downwards
	 */
	function searchFromCurrentIndex(searchUpwards) {
		if (!Kirigami.Settings.isMobile && !searchField.activeFocus)
			searchField.forceActiveFocus()

		search(searchUpwards, messageListView.currentIndex + (searchUpwards ? 1 : -1))
	}

	/**
	 * Searches for a message containing the entered text in the search field.
	 *
	 * If a message is found for the entered text, that message is highlighted.
	 *
	 * @param searchUpwards true for searching upwards or false for searching downwards
	 * @param startIndex index of the first message to search for the entered text
	 */
	function search(searchUpwards, startIndex) {
        newIndex = -1
		const searchedString = searchField.text

		if (searchedString.length > 0) {
			searchFieldBusyIndicator.running = true

			if (searchUpwards) {
				if (startIndex === 0) {
					messageListView.currentIndex = MessageModel.searchForMessageFromNewToOld(searchedString)
				} else {
					newIndex = MessageModel.searchForMessageFromNewToOld(searchedString, startIndex)
					if (newIndex !== -1) {
						messageListView.currentIndex = newIndex
					}
				}

				if (messageListView.currentIndex !== -1) {
					searchFieldBusyIndicator.running = false
				}
			} else {
				newIndex = MessageModel.searchForMessageFromOldToNew(searchedString, startIndex)

				if (newIndex !== -1) {
					messageListView.currentIndex = newIndex
				}

				searchFieldBusyIndicator.running = false
			}
		}
	}
}
