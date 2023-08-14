// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * This is used for a single action without an instantaneous result.
 */
LoadingStackArea {
	default property alias __data: contentArea.data
	property alias confirmationButton: confirmationButton

    Column {
		id: contentArea
        spacing: Theme.paddingLarge
	}

	CenteredAdaptiveHighlightedButton {
		id: confirmationButton
	}
}
