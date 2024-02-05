// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2019 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbblp@protonmail.ch>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0
import "elements"

/**
 * This page is used for logging in by scanning a QR code which contains an XMPP login URI.
 */
Page {
	id: root

    PageHeader {
        title: qsTr("Scan QR code")
    }

    Column {
        id: column

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Theme.paddingLarge

        Button {
            text: qsTr("Scan QR code")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                if (!scanner.cameraEnabled) {
                    scanner.camera.start()
                    scanner.cameraEnabled = true
                }
            }
        }
        Button {
            text: qsTr("Continue without QR code")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                pageStack.push(registrationLoginDecisionPage)
            }
        }
    }

    QrCodeScanner {
		id: scanner

		property bool acceptResult: true

		cornersRounded: false
		anchors.fill: parent
//        zoomSliderArea.anchors.bottomMargin: Kirigami.Units.largeSpacing * 11
//        zoomSliderArea.width: Math.min(largeButtonWidth, parent.width - Kirigami.Units.largeSpacing * 4)
		filter.onScanningSucceeded: {
			if (acceptResult) {
				// Try to log in by the data from the decoded QR code.
				switch (Kaidan.logInByUri(result)) {
				case Enums.Connecting:
					break
				case Enums.PasswordNeeded:
                    pageStack.push(loginPage)
					break
				case Enums.InvalidLoginUri:
					acceptResult = false
					resetAcceptResultTimer.start()
                    showPassiveNotification(qsTr("This QR code is not a valid login QR code."), 4)
				}
			}
		}

		LoadingArea {
			anchors.centerIn: parent
			description: qsTr("Connecting…")
			visible: Kaidan.connectionState === Enums.StateConnecting
		}

		// timer to accept the result again after an invalid login URI was scanned
		Timer {
			id: resetAcceptResultTimer
            interval: 10 * 4
			onTriggered: scanner.acceptResult = true
		}
	}
}
