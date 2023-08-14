// SPDX-FileCopyrightText: 2018 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
// import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

/**
 * This sheet is used on desktop systems instead of a new layer. It doesn't
 * fill the complete width, so it looks a bit nicer on large screens.
 */
DockedPanel {
	id: settingsSheet
	Kirigami.Theme.inherit: false
	//FIXME Kirigami.Theme.colorSet: Kirigami.Theme.Window
	leftPadding: 0
	rightPadding: 0
	header: Row {
		anchors.fill: parent
		spacing: 1
		Controls.ToolButton {
			id: backButton
			enabled: stack.currentItem !== stack.initialItem
			icon.source: "draw-arrow-back"
			onClicked: stack.pop()
		}
		SectionHeader {
			width: parent.width
			//FIXME // Layout.alignment: Qt.AlignVCenter
			text: stack.currentItem.title
		}
	}

	 Controls.StackView {
		//FIXME Layout.fillHeight: true
		width: parent.width

		id: stack
		implicitHeight: currentItem.implicitHeight
		implicitWidth: 600

		initialItem: SettingsContent {}
		clip: true
	}
}
