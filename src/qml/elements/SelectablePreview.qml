// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * Used to show a selectable preview (e.g., of an image or video).
 */
GridItem {
    id: root

	property bool checkable : true
	property bool checked : false
	signal toggled

	width: GridView.view.cellWidth
	height: GridView.view.cellHeight

	onClicked: {
		checked = !checked
		root.toggled()
	}
}
