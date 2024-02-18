// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This is used for actions without instantaneous results.
 */
Item {
    default property alias __data: contentArea.data
    property alias loadingArea: loadingArea
    property int currentIndex: 0
    width: parent.width

    Column {
        id: contentArea
        visible: currentIndex == 0
        spacing: Theme.paddingLarge * 2
        width: parent.width
    }

    LoadingArea {
        id: loadingArea
        visible: currentIndex == 1
        background.color: secondaryBackgroundColor
    }

    function showLoadingView() {
        currentIndex = 1
    }

    function hideLoadingView() {
        currentIndex = 0
    }
}
