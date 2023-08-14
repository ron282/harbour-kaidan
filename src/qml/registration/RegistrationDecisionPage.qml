// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0

/**
 * This page is used for deciding between the automatic or manual registration.
 */
Page {
        Column {
            anchors.top: parent.top
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Register")
            }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
//            icon: Image {
//                source: Utils.getResourcePath("images/onboarding/automatic-registration.svg")
//            }
            text: qsTr("Generate an account automatically")
            onClicked: pageStack.push(automaticRegistrationPage)
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
//            icon: Image {
//                source: Utils.getResourcePath("images/onboarding/manual-registration.svg")
//            }
            text: qsTr("Create an account manually")
            onClicked: pageStack.push(manualRegistrationPage)
        }
    }
}
