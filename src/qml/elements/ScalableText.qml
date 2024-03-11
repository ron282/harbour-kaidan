// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This is a text that can be scaled.
 */
Label {
	// factor to scale the text
	property double scaleFactor: 1

	font.pixelSize: Theme.fontSizeMedium * scaleFactor
}
