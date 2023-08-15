// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a form button delegate for a URL.
 *
 * Its main purpose is to open the URL externally when the button is clicked.
 * It includes a secondary button for copying the URL instead of opening it.
 */
Row {
    width: parent.width
    property alias url: valbut.label
    property alias icon: icon.source
    property alias description: valbut.description

    Icon {
        id: icon
        width: Theme.iconSizeMedium
    }
    ValueButton {
        id: valbut
        width: parent.width - icon.width - but.width
        onClicked: Qt.openUrlExternally(url)

    }
    Button {
        id: but
        width: Theme.iconSizeMedium
        icon.source: "image://theme/icon-m-clipboard"
        onClicked: Utils.copyToClipboard(url)
   }
}
