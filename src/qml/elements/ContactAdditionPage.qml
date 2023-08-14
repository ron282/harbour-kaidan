// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
	id: root

	property alias jid: content.jid
	property alias name: content.name

    PageHeader
    {
        title: qsTr("Add contact")
    }

	Component.onCompleted: content.jidField.forceActiveFocus()

	ContactAdditionContent {
		id: content
	}
}
