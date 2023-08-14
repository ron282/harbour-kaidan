// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This view shows a busy indicator.
 *
 * It is displayed during network interaction.
 */
ViewPlaceholder {
  text: qsTr("Requesting the server…")

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
	}
}
