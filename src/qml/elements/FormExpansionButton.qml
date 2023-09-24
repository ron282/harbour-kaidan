// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * Used to expand and collapse form entries.
 */
BackgroundItem {
	id: root
    property bool checkable: true
    property bool checked : false
    contentHeight: Theme.itemSizeSmall
    width: Theme.itemSizeSmall
    onClicked: { checked = !checked }
    HighlightImage {
        source: root.checked ? "image://theme/icon-splus-hide-password" : "image://theme/icon-splus-show-password"
        anchors.centerIn: parent
    }
}

