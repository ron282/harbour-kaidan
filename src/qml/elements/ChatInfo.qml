// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

//import QtQuick 2.14
//import QtQuick.Controls 2.14 as Controls
//import org.kde.kirigami 2.19 as Kirigami

Label {
    color: Theme.secondaryColor
	leftPadding: font.pixelSize * 0.7
	rightPadding: leftPadding
	topPadding: leftPadding * 0.4
	bottomPadding: topPadding
    Rectangle  {
        color: Qt.darker(primaryBackgroundColor, 1.2)
		radius: parent.height * 0.5
	}
}
