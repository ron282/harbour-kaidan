// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0
// import QtQuick.Controls 2.14 as Controls
// import org.kde.kirigami 2.19 as Kirigami
// import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

/**
 * The settings page contains options to configure Kaidan.
 *
 * It is used on a new layer on mobile and inside of a Sheet on desktop.
 */
Column {
    id: mainColumn

    PageHeader {
        id: header
        title: qsTr("Settings")
    }

    Button {
        text: qsTr("Multimedia Settings")
        //FIXME description: qsTr("Configure photo, video and audio recording settings")
        onClicked: pageStack.push("qrc:/qml/settings/MultimediaSettings.qml")
        icon.source: "emblem-system-symbolic"
    }

    Button {
        text: qsTr("About Kaidan")
        //FIXME description: qsTr("Learn about the current Kaidan version, view the source code and contribute")
        onClicked: pageStack.push("qrc:/qml/settings/AboutPage.qml")
        icon.source: "help-about-symbolic"
    }
}
