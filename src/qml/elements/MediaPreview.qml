// SPDX-FileCopyrightText: 2018 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2018 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * This element is used in the @see SendMediaSheet to display information about a selected file to
 * the user. It shows the file name, file size and a little file icon.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
// import QtQuick.Controls 2.14 as Controls
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

Rectangle {
	id: root

	property url mediaSource
    property int mediaSourceType: Enums.MessageUnknown
    property int messageSize: Theme.paddingLarge
	property QtObject message
	property QtObject mediaSheet

//	color: message ? 'transparent' : Kirigami.Theme.backgroundColor

	//FIXME Layout.fillHeight: false
    width: message ? parent.width : undefined
	// Layout.alignment: Qt.AlignCenter
	anchors.topMargin: -6
	anchors.leftMargin: anchors.topMargin
	anchors.rightMargin: anchors.topMargin
}
