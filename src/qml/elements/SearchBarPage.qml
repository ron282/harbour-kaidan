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

    function toggleSearchBar() {
        if(searchField) {
            searchField.visible = !searchField.visible
            if(searchField.visible)
                Qt.inputMethod.show()
            else
                Qt.inputMethod.hide()
        }
	}

	function resetSearchBar() {
        if(searchField)
            searchField.visible = false
    }
}
