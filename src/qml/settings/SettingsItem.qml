// SPDX-FileCopyrightText: 2018 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
// import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

Kirigami.BasicListItem {
	property string name
	property string description

	reserveSpaceForIcon: icon

	 Column {
		SectionHeader {
			text: name
			textFormat: Text.PlainText
			elide: Text.ElideRight
			maximumLineCount: 1
			level: 2
			width: parent.width
			Layout.maximumHeight: Kirigami.Units.gridUnit * 1.5
		}

		Label {
			width: parent.width
			text: description
			wrapMode: Text.WordWrap
			textFormat: Text.PlainText
		}
	}
}
