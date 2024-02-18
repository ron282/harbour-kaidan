// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This area is used to interact with encryption devices and their keys.
 */
Flow {
	property alias header: header
	property alias listView: listView

    height: parent.flow === Flow.LeftToRight ? parent.height : parent.height / 2 - parent.rowSpacing * 2
    width:  parent.width

    Column {
        width: parent.width
        height: parent.height

        spacing: 0

        SectionHeader {
            id: header
        }

        SilicaListView {
            id: listView
            width: parent.width
            height: parent.height - header.height

            clip: true
        }
    }
}

