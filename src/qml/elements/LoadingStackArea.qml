// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This is used for actions without instantaneous results.
 */
BackgroundItem {
	default property alias __data: contentArea.data
	property alias loadingArea: loadingArea

    Column {
		id: contentArea
        spacing: Theme.paddingLarge* 2
	}

	LoadingArea {
		id: loadingArea
		background.color: secondaryBackgroundColor
	}

	function showLoadingView() {
		currentIndex = 1
	}

	function hideLoadingView() {
		currentIndex = 0
	}
}
