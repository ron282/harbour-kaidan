// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0

import "elements"

/**
 * This page is the first page.
 *
 * It is displayed if no account is available.
 */
Page {
    PageHeader {
        title: "Kaidan"
    }
    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Theme.paddingLarge


        HighlightImage {
            source: Utils.getResourcePath("images/kaidan.svg")
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width
            sourceSize.height: width
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: startButton
            text: qsTr("Let's start")
            onClicked: pageStack.push(qrCodeOnboardingPage)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
		target: Kaidan

		function onConnectionErrorChanged() {
			if (Kaidan.connectionError !== ClientWorker.NoError)
				passiveNotification(Utils.connectionErrorMessage(Kaidan.connectionError))
		}
	}
}
