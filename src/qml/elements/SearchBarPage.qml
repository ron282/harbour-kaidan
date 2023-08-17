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
    property PullDownMenu pullDownMenu
    property SearchBarPageSearchField searchField
	property bool isSearchActionShown: true

    pullDownMenu : PullDownMenu {
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

        SearchBarPageSearchField {
            id: searchField
            listView: root.listView
            anchors {
                right: parent.right
                left: parent.left
            }
        }
    }

	function toggleSearchBar() {
        if (listView.header) {
            searchField.visible = false
		} else {
            searchField.visible = true
		}
	}

	function resetSearchBar() {
        searchField.visible = false
    }
}
