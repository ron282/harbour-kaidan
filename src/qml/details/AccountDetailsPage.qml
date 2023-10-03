// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0

DetailsPage {
	id: root

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + content.height
        contentWidth: parent.width
        clip: true

        AccountDetailsHeader {
            id: header
            jid: AccountManager.jid
        }

        AccountDetailsContent {
            id: content
            jid: AccountManager.jid
            anchors.top: header.bottom
        }
    }
}
