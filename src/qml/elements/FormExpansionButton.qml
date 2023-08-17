// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

/**
 * Used to expand and collapse form entries.
 */
Button {
	id: root
    property boo checkable: true
    icon.source: root.checked ? "image://theme/icon-m-up" : "image://theme/icon-m-up"
    width: Theme.iconSizeSmall
    height: width
}
