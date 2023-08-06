// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

SilicaFlickable {
	id: root

	default property alias __data: mainArea.data

    //FIXME leftPadding: 0
    //FIXME rightPadding: 0
    //FIXME Kirigami.Theme.colorSet: Kirigami.Theme.Window
    contentWidth: parent.width
    contentHeight: mainArea.height
	Column {
		id: mainArea
	}
}
