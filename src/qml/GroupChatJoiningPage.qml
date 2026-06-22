// SPDX-FileCopyrightText: 2024 ron282 <ronan35@gmx.fr>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

Page {
    id: root

    property string groupChatJid: ""

    Component.onCompleted: {
        if (groupChatJid.length > 0)
            jidField.text = groupChatJid
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Join Group Chat")
            }

            TextField {
                id: jidField
                width: parent.width
                label: qsTr("Address")
                placeholderText: qsTr("group@groups.example.org")
                inputMethodHints: Qt.ImhEmailCharactersOnly | Qt.ImhPreferLowercase
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: nicknameField.forceActiveFocus()
            }

            TextField {
                id: nicknameField
                width: parent.width
                label: qsTr("Nickname (optional)")
                placeholderText: AccountManager.displayName
                inputMethodHints: Qt.ImhPreferUppercase
                EnterKey.enabled: jidField.text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: joinGroupChat()
            }

            Label {
                id: errorLabel
                width: parent.width - 2 * Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                visible: text.length > 0
                color: Theme.errorColor
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Join")
                enabled: jidField.text.length > 0 && !Kaidan.groupChatController.busy
                onClicked: joinGroupChat()
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: Kaidan.groupChatController.busy
                visible: running
            }
        }
    }

    Connections {
        target: Kaidan.groupChatController

        onGroupChatJoined: {
            pageStack.pop()
        }

        onGroupChatJoiningFailed: {
            errorLabel.text = errorMessage
                ? qsTr("Could not join %1: %2").arg(groupChatJid).arg(errorMessage)
                : qsTr("Could not join %1").arg(groupChatJid)
        }
    }

    function joinGroupChat() {
        if (jidField.text.length === 0)
            return
        errorLabel.text = ""
        var nick = nicknameField.text.length > 0
            ? nicknameField.text
            : AccountManager.displayName
        Kaidan.groupChatController.joinGroupChat(jidField.text, nick)
    }
}
