/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

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
        title: "Kaidan"
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
		anchors.fill: parent

		Item {
			anchors.centerIn: parent

            Column {
				id: loadingArea
                width: parent.width
				visible: Kaidan.connectionState === Enums.StateConnecting

                BusyIndicator {
                    anchors.centerIn: loadingArea
                }

                Label {
					text: "<i>" + qsTr("Connecting…") + "</i>"
				}
			}
		}

		filter.onScanningSucceeded: {
			if (acceptResult) {
				// Try to log in by the data from the decoded QR code.
				switch (Kaidan.logInByUri(result)) {
				case Enums.Connecting:
					break
				case Enums.PasswordNeeded:
					pageStack.layers.push(loginPage)
					break
				case Enums.InvalidLoginUri:
					acceptResult = false
					resetAcceptResultTimer.start()
					showPassiveNotification(qsTr("This QR code is not a valid login QR code."), Kirigami.Units.veryLongDuration * 4)
				}
			}
		}

		property bool acceptResult: true

		// timer to accept the result again after an invalid login URI was scanned
		Timer {
			id: resetAcceptResultTimer
            interval: 10 * 4
			onTriggered: scanner.acceptResult = true
		}
	}
}
