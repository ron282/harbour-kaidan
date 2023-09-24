// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a centered button having an adjustable label and fitting its parent's width.
 */
Column {
    id: root
    property bool checkable : false
    property string text
    property alias checked: checkableButton.checked
    anchors.horizontalCenter: parent.horizontalCenter
    width: Theme.buttonWidthLarge
    signal clicked
    Button {
       id: pushButton
       width: root.width
       text: root.text
       visible: !root.checkable
       onClicked: root.clicked()
    }
    TextSwitch {
        id: checkableButton
        text: root.text
        width: root.width
        visible: root.checkable
        onCheckedChanged: {
            checkable = true
            root.clicked()
       }
    }
}
