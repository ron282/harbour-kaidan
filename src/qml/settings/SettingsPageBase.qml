// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import QtQuick.Controls 2.14 as Controls

// import org.kde.kirigami 2.19 as Kirigami

Item {
	property string title

	property real topPadding: 0
	property real bottomPadding: 0
	property real leftPadding: 0
	property real rightPadding: 0

	//FIXME Layout.fillHeight: true
	width: parent.width
}
