// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This is a centered and adaptive text.
 */
Label {
	// factor to scale the text
	property double scaleFactor: 1
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter

    horizontalAlignment: Text.AlignHCenter
	wrapMode: Text.WordWrap
    elide: Text.ElideRight
    font.pixelSize: Theme.fontSizeMedium * scaleFactor
//=======
//ScalableText {
//	Layout.fillWidth: true
//	horizontalAlignment: Text.AlignHCenter
//	wrapMode: Text.WordWrap
//	elide: Text.ElideRight
//>>>>>>> master
}
