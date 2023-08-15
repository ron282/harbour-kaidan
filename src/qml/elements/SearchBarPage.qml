// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a base for pages containing a list view.
 *
 * It adds a search bar for searching items within the list view.
 */
Page {
	id: root

    property SilicaListView listView
	property SearchBarPageSearchField searchField
	property bool isSearchActionShown: true

    listView.pullDownMenu : PullDownMenu {
        MenuItem {
			text: qsTr("Search")
			visible: isSearchActionShown
            onClicked: {
                toggleSearchBar()
			}
		}
	}

	Component {
		id: mobileSearchBarComponent

            Column {
				id: contentArea
				width: parent.width - 30
				anchors.centerIn: parent
				spacing: 10

				SearchBarPageSearchField {
					listView: root.listView
                    anchors {
                        right: parent.right
                        left: parent.left
                    }

					Component.onCompleted: {
						root.searchField = this
					}
				}
			}

            Separator {

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
        if (listView.header) {
			searchField.text = ""
            listView.header.close()
		} else {
            listView.header = mobileSearchBarComponent.createObject()
            listView.header.open()
		}
	}

	function resetSearchBar() {
        listView.header = null
	}
}
