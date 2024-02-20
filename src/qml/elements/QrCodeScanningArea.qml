// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbblp@protonmail.ch>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

Flow {
	id: root

	property string accountJid

	// Used for authenticating or distrusting keys via QR code scanning.
	property string chatJid
	readonly property bool forOwnDevices: accountJid === chatJid
	readonly property bool onlyForTrustDecisions: forOwnDevices || chatJid

    spacing: Theme.paddingLarge * 2
    readonly property int rowSpacing: spacing
    readonly property int columnSpacing: spacing

	property alias scanner: scanner

    flow: parent.width > parent.height ? Flow.LeftToRight : Flow.TopToBottom
    width:  flow === Flow.LeftToRight ? parent.width : Math.min(parent.width, parent.height / 2 - rowSpacing * 2)
    height: flow === Flow.TopToBottom ? parent.height : Math.min(parent.height, parent.width / 2 - columnSpacing * 2)


	QrCodeScanner {
		id: scanner

		property bool isAcceptingResult: true
		property bool isBusy: false

        width: parent.flow === Flow.TopToBottom ? parent.width : parent.height
        height: width

		// Use the data from the decoded QR code.
		filter.onScanningSucceeded: {
			if (isAcceptingResult) {
				isBusy = true
                var processTrust = true

				// Try to add a contact.
				if (!root.onlyForTrustDecisions) {
					switch (RosterModel.addContactByUri(root.accountJid, result)) {
					case RosterModel.AddingContact:
                        showPassiveNotification(qsTr("Contact added - Continue with step 2"), 1000 * 4)
						break
					case RosterModel.ContactExists:
						processTrust = false
						break
					case RosterModel.InvalidUri:
						processTrust = false
                        showPassiveNotification(qsTr("This QR code does not contain a contact"), 1000 * 4)
					}
				}

				// Try to authenticate or distrust keys.
				if (processTrust) {
                    var expectedJid = ""

					if (root.onlyForTrustDecisions) {
						expectedJid = root.chatJid
					}

					switch (Kaidan.makeTrustDecisionsByUri(result, expectedJid)) {
					case Kaidan.MakingTrustDecisions:
						if (root.forOwnDevices) {
                            showPassiveNotification(qsTr("Trust decisions made for other own device - Continue with step 2"), 1000 * 4)
						} else {
                            showPassiveNotification(qsTr("Trust decisions made for contact - Continue with step 2"), 1000 * 4)
						}

						break
					case Kaidan.JidUnexpected:
						if (root.onlyForTrustDecisions) {
							if (root.forOwnDevices) {
                                showPassiveNotification(qsTr("This QR code is not for your other device"), 1000 * 4)
							} else {
                                showPassiveNotification(qsTr("This QR code is not for your contact"), 1000 * 4)
							}
						}
						break
					case Kaidan.InvalidUri:
						if (root.onlyForTrustDecisions) {
                            showPassiveNotification(qsTr("This QR code is not for trust decisions"), 1000 * 4)
						}
					}
				}

				isBusy = false
				isAcceptingResult = false
				resetAcceptResultTimer.start()
			}
		}

		// timer to accept the result again after an invalid URI was scanned
		Timer {
			id: resetAcceptResultTimer
            interval: 4000
			onTriggered: scanner.isAcceptingResult = true
		}

		LoadingArea {
			description: root.onlyForTrustDecisions ? qsTr("Making trust decisions…") : qsTr("Adding contact…")
			anchors.centerIn: parent
			visible: scanner.isBusy
		}
	}

    Separator {
        width: parent.flow === Flow.TopToBottom ? parent.width : parent.height
        anchors.topMargin: parent.flow === Flow.LeftToRight ? parent.height * 0.1 : 0
        anchors.bottomMargin: anchors.topMargin
        anchors.leftMargin: parent.flow === Flow.TopToBottom ? parent.width * 0.1 : 0
        anchors.rightMargin: anchors.leftMargin
//		Layout.alignment: Qt.AlignCenter
    }

	QrCode {
//		Layout.fillWidth: parent.flow === GridLayout.TopToBottom
//		Layout.fillHeight: parent.flow === GridLayout.LeftToRight
//		Layout.preferredWidth: height
//		Layout.preferredHeight: width
//		Layout.alignment: Qt.AlignCenter
        width: parent.flow === Flow.TopToBottom ? parent.width : parent.height
        height: width
    }
}
