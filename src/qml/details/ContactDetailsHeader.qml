// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
// import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

import "../elements"

DetailsHeader {
	id: root
	displayName: contactWatcher.item.displayName
    Button {
		text: qsTr("Maximize avatar")
        icon.source: "image://theme/icon-m-device"
		enabled: Kaidan.avatarStorage.getAvatarUrl(jid)
        onClicked: Qt.openUrlExternally(Kaidan.avatarStorage.getAvatarUrl(jid))
	}

	RosterItemWatcher {
		id: contactWatcher
		jid: root.jid
	}

	function displayNameChangeFunction(newDisplayName) {
		Kaidan.client.rosterManager.renameContactRequested(root.jid, newDisplayName)
	}

	function displayNameChangedFunction() {}
}
