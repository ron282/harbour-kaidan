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
	SilicaFlickable {
		anchors.fill: parent
		contentHeight: col.height

		Column {
			id: col
			width: parent.width
			spacing: Theme.paddingLarge

			Rectangle {
				color: "transparent"
				width: parent.width
				height: Theme.paddingLarge
			}

			HighlightImage {
				source: Utils.getResourcePath("images/kaidan.svg")
				fillMode: Image.PreserveAspectFit
				sourceSize.width: width
				sourceSize.height: width
				anchors.horizontalCenter: parent.horizontalCenter
			}

			CenteredAdaptiveText {
				text: "Kaidan"
				scaleFactor: 4
			}

			CenteredAdaptiveText {
				text: qsTr("Enjoy free communication on every device!")
				scaleFactor: 1.5
			}

			SectionHeader {
				text: qsTr("Login")
			}

			TextSwitch {
				text: qsTr("Enter your credentials")
				onClicked: loginArea.visible = !loginArea.visible
			}

			LoginArea {
				id: loginArea
				visible: false
				onVisibleChanged: {
					if (visible) {
						initialize()
					} else {
						reset()
					}
				}

				Connections {
					target: pageStack.layers

					function onCurrentItemChanged() {
						if (AccountManager.jid) {
							loginArea.visible = true
						}
					}
				}
			}

			Button {
				text: qsTr("Scan login QR code of old device")
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: openPage(qrCodeOnboardingPage)
			}

			SectionHeader {
				text: qsTr("or Register")
			}

			Button {
				text: qsTr("Generate account automatically")
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: openPage(automaticRegistrationPage)
			}

			Button {
				text: qsTr("Create account manually")
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: openPage(manualRegistrationPage)
			}

			Connections {
				target: Kaidan

				function onConnectionErrorChanged() {
					if (Kaidan.connectionError !== ClientWorker.NoError)
						passiveNotification(Utils.connectionErrorMessage(Kaidan.connectionError))
				}
			}
		}
	}
}
