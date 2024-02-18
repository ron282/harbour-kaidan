// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: root

    property alias background: background
    property alias description: description.text

    RoundedRectangle {
        id: background
        anchors.fill: content
        anchors.margins: -8
        color: primaryBackgroundColor
        opacity: 0.9
    }

    Column {
        id: content
        anchors.centerIn: parent

        BusyIndicator {
        }

        Label {
            id: description
            text: qsTr("Loading…")
            font.italic: true
        }
    }
}
