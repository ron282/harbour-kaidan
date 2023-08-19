// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbblp@protonmail.ch>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "elements"

/**
 * This page is used for scanning QR codes and displaying an own QR code which
 * can be scanned.
 */
ExplanationTogglePage {
    id: root

    // Used for authenticating or distrusting keys via QR code scanning.
    property bool isOnlyForTrustDecisions: isForOwnDevices || contactJid
    property bool isForOwnDevices: false
    property string contactJid

    title: qsTr("Scan QR codes")
    explanationArea.visible: Kaidan.settings.qrCodePageExplanationVisible
    primaryButton.text: primaryButton.checked ? qsTr("Show explanation") : qsTr("Scan QR codes")
    primaryButton.checked: !Kaidan.settings.qrCodePageExplanationVisible

    primaryButton.onClicked: {
        if (Kaidan.settings.qrCodePageExplanationVisible) {
            // Hide the explanation when this page is opened again in the future.
            Kaidan.settings.qrCodePageExplanationVisible = false

            if (!scanner.cameraEnabled) {
                scanner.camera.start()
                scanner.cameraEnabled = true
            }
        }
    }

    secondaryButton.visible: false

    explanation: Column {

            CenteredAdaptiveText {
                text: {
                    if (root.isForOwnDevices) {
                        return qsTr("Step 1: Scan your <b>other device's</b> QR code")
                    }
                    return qsTr("Step 1: Scan your <b>contact's</b> QR code")
                }
            }

            Image {
                source: Utils.getResourcePath(root.isForOwnDevices ? "images/qr-code-scan-own-1.svg" : "images/qr-code-scan-1.svg")
                sourceSize: Qt.size(Screen.width-2*Theme.horizontalPageMargin, Screen.width-2*Theme.horizontalPageMargin)
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

        Separator {
        }

        CenteredAdaptiveText {
            text: {
                if (root.isForOwnDevices) {
                    return qsTr("Step 2: Scan with your other device <b>this device's</b> QR code")
                }
                return qsTr("Step 2: Let your contact scan <b>your</b> QR code")
            }
        }

        Image {
            source: Utils.getResourcePath(root.isForOwnDevices ? "images/qr-code-scan-own-2.svg" : "images/qr-code-scan-2.svg")
            sourceSize: Qt.size(Screen.width-2*Theme.horizontalPageMargin, Screen.width-2*Theme.horizontalPageMargin)
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    content: Column {
        visible: !Kaidan.settings.qrCodePageExplanationVisible
        width: parent.width
        height: parent.height
//        width: applicationWindow().wideScreen ? parent.width : Math.min(largeButtonWidth, parent.width, parent.height * 0.48)
//        height: applicationWindow().wideScreen ? Math.min(parent.height, parent.width * 0.48) : parent.height

        QrCodeScanner {
            id: scanner
            width: parent.width

            // Use the data from the decoded QR code.
            filter.onScanningSucceeded: {
                if (isAcceptingResult) {
                    isBusy = true
                    var processTrust = true

                    // Try to add a contact.
                    if (!root.isOnlyForTrustDecisions) {
                        switch (RosterModel.addContactByUri(result)) {
                        case RosterModel.AddingContact:
                            showPassiveNotification(qsTr("Contact added - Continue with step 2"), Kirigami.Units.veryLongDuration * 4)
                            break
                        case RosterModel.ContactExists:
                            processTrust = false
                            break
                        case RosterModel.InvalidUri:
                            processTrust = false
                            showPassiveNotification(qsTr("This QR code does not contain a contact"), Kirigami.Units.veryLongDuration * 4)
                        }
                    }

                    // Try to authenticate or distrust keys.
                    if (processTrust) {
                        var expectedJid = ""
                        if (root.isOnlyForTrustDecisions) {
                            expectedJid = root.isForOwnDevices ? AccountManager.jid : root.contactJid
                        }
                        switch (Kaidan.makeTrustDecisionsByUri(result, expectedJid)) {
                        case Kaidan.MakingTrustDecisions:
                            if (root.isForOwnDevices) {
                                showPassiveNotification(qsTr("Trust decisions made for other own device - Continue with step 2"), Kirigami.Units.veryLongDuration * 4)
                            } else {
                                showPassiveNotification(qsTr("Trust decisions made for contact - Continue with step 2"), Kirigami.Units.veryLongDuration * 4)
                            }

                            break
                        case Kaidan.JidUnexpected:
                            if (root.isOnlyForTrustDecisions) {
                                if (root.isForOwnDevices) {
                                    showPassiveNotification(qsTr("This QR code is not for your other device"), Kirigami.Units.veryLongDuration * 4)
                                } else {
                                    showPassiveNotification(qsTr("This QR code is not for your contact"), Kirigami.Units.veryLongDuration * 4)
                                }
                            }
                            break
                        case Kaidan.InvalidUri:
                            if (root.isOnlyForTrustDecisions) {
                                showPassiveNotification(qsTr("This QR code is not for trust decisions"), Kirigami.Units.veryLongDuration * 4)
                            }
                        }
                    }

                    isBusy = false
                    isAcceptingResult = false
                    resetAcceptResultTimer.start()
                }
            }

            property bool isAcceptingResult: true
            property bool isBusy: false

            // timer to accept the result again after an invalid URI was scanned
            Timer {
                id: resetAcceptResultTimer
                interval: 1000 * 4
                onTriggered: scanner.isAcceptingResult = true
            }

            LoadingArea {
                description: root.isOnlyForTrustDecisions ? qsTr("Making trust decisions…") : qsTr("Adding contact…")
                anchors.centerIn: parent
                visible: scanner.isBusy
            }
        }

        Separator {
        }

        QrCode {
            width: parent.width
        }
    }

    Component.onCompleted: {
        if (!Kaidan.settings.qrCodePageExplanationVisible) {
            scanner.camera.start()
            scanner.cameraEnabled = true
        }
    }
}
