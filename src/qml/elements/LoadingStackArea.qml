// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This is used for actions without instantaneous results.
 */
Column {
    property alias contentArea: contentAreaZone.data
	property alias loadingArea: loadingArea

    anchors.top: parent.top
    anchors.topMargin: Theme.itemSizeLarge
    width: parent.width

    Column {
        id: contentAreaZone
        width: parent.width
	}

	LoadingArea {
		id: loadingArea
        anchors.fill: parent
//		background.color: secondaryBackgroundColor
	}

	function showLoadingView() {
        loadingArea.running = true
	}

	function hideLoadingView() {
        loadingArea.running = false
    }
}
