// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
// import org.kde.kirigami 2.19 as Kirigami
import Sailfish.Silica 1.0

Page {
	title: pageLoader.item ? pageLoader.item.title : ""

	leftPadding: pageLoader.item ? pageLoader.item.leftPadding : 0
	rightPadding: pageLoader.item ? pageLoader.item.rightPadding : 0
	topPadding: pageLoader.item ? pageLoader.item.topPadding : 0
	bottomPadding: pageLoader.item ? pageLoader.item.bottomPadding : 0

	property alias source: pageLoader.source

	Loader {
		id: pageLoader

		anchors.fill: parent

		active: true

		onItemChanged: {
			item.parent = pageLoader
		}
	}
}
