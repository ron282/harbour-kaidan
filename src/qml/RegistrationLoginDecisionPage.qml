// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0


/**
 * This page is used for deciding between registration or login.
 */
Page {
    PageHeader {
        title : qsTr("Set up")
    }
    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Theme.paddingLarge

        Button {
            text: qsTr("Register a new account")            
            icon.source: Utils.getResourcePath("images/onboarding/registration.svg")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(registrationDecisionPage)
        }

        Button {
            text: qsTr("Use an existing account")
            icon.source: Utils.getResourcePath("images/onboarding/login.svg")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(loginPage)
        }
    }
}
