// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: root

    property alias background: background
    property alias description: description.text

    Rectangle {
        id: background
        anchors.fill: parent
        color: "transparent"
    }

    BusyLabel {
        id: description
        text: qsTr("Loading…")
        running: root.visible
        anchors.fill: parent
    }
}
