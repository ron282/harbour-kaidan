// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

//import QtQuick 2.14
//import QtQuick.Layouts 1.14
//import org.kde.kirigami 2.19 as Kirigami
import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a base for pages containing a list view.
 *
 * It adds a search bar for searching items within the list view.
 */
//Kirigami.ScrollablePage {
	Page {
	id: root

    property SilicaListView listView
    property SearchBarPageSearchField searchField
	property bool isSearchActionShown: true
	property var header

//	background: Rectangle {
//		color: primaryBackgroundColor
//	}

//	actions {
//		main: Kirigami.Action {
//			text: qsTr("Search")
//			icon.name: "system-search-symbolic"
//			visible: isSearchActionShown
//			checkable: Kirigami.Settings.isMobile
//			displayComponent: Kirigami.Settings.isMobile ? null : desktopSearchBarComponent
//			onTriggered: {
//				if (Kirigami.Settings.isMobile) {
//					toggleSearchBar()
//				} else {
//					searchField.activeFocusForced()
//				}
//			}
//		}
//	}

	Component {
		id: desktopSearchBarComponent

		SearchBarPageSearchField {
			listView: root.listView
			anchors.left: parent.left
			width: root.actions.right ? parent.width - Kirigami.Units.iconSizes.medium - Kirigami.Units.smallSpacing : parent.width

			Connections {
				target: searchFieldFocusTimer

				function onTriggered() {
					forceActiveFocus()
				}
			}

			// timer to focus the search field because other declarative approaches do not work
			Timer {
				id: searchFieldFocusTimer
				interval: 100
			}

			Component.onCompleted: {
				root.searchField = this

				// The following makes it possible on desktop devices to directly search after opening this page.
				// It is not used on mobile devices because the soft keyboard would otherwise always pop up after opening this page.
				if (!Kirigami.Settings.isMobile) {
					searchFieldFocusTimer.start()
				}
			}
		}
	}

	Component {
			id: mobileSearchBarComponent

			Rectangle {
				property bool active: false

				visible: height != 0
				width: parent ? parent.width : 0
				height: active ? (contentArea.height + contentArea.spacing * 2) : 0
				clip: true
				color: secondaryBackgroundColor
				onHeightChanged: {
					if (height === 0) {
						root.resetSearchBar()
					}
				}

				Behavior on height {
					SmoothedAnimation {
						velocity: 550
					}
				}

//				ColumnLayout {
				Column {
					id: contentArea
//					width: parent.width - 30
					width: parent.width
					anchors.centerIn: parent
					spacing: 10

					SearchBarPageSearchField {
						listView: root.listView
//						Layout.fillWidth: true
						width: parent.width
						Component.onCompleted: {
							root.searchField = this
						}
					}
				}

				// colored separator
				Rectangle {
					height: 1
//					color: Kirigami.Theme.disabledTextColor
					anchors.left: parent ? parent.left : undefined
					anchors.right: parent ? parent.right : undefined
					anchors.bottom: parent ? parent.bottom : undefined
				}

				function open() {
					searchField.forceActiveFocus()
					active = true
				}

				function close() {
					active = false
				}
			}
		}

    function toggleSearchBar() {
//        if (header) {
//			searchField.text = ""
//			header.close()
//		} else {
//			header = mobileSearchBarComponent.createObject()
//			header.open()
//		}
		searchField.visible = !searchField.visible
	}

	function resetSearchBar() {
//		header = null
//		root.actions.main.checked = false
        searchField.visible = false
    }
}
