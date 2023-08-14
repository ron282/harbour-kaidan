// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This page is the base for confirmation pages.
 *
 * It provides an adjustable description, a configurable confirmation button and a predefined cancel button.
 */
BinaryDecisionPage {
    topImageSource: "image://theme/icon-m-enter-accept"
	bottomImageSource: "dialog-cancel"
	topActionAsMainAction: true

	signal canceled

	bottomAction: Button {
		text: qsTr("Cancel")
		onTriggered: canceled()
	}
}
