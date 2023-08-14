// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Robert Maerkisch <zatrox@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

Rectangle {
    property int count: 0
    property bool muted: false
    width: Math.max(lblUnread.implicitWidth+radius, height)
    height: lblUnread.implicitHeight
    color: Theme.highlightBackgroundColor
    radius: height*0.5
    visible: (count > 0) ? true : false
    Label {
        id: lblUnread
        font.bold: true
        text: count > 9999 ? "9999+" : count
        font.pixelSize: Theme.fontSizeTiny
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
