// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"

Row {
    id: root
    spacing: Theme.paddingSmall

//    default property alias __data: mainArea.data
    property string jid
    property string displayName
    property Button avatarAction

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: Theme.horizontalPageMargin
        rightMargin: Theme.horizontalPageMargin
        top: parent.top
    }

    height: Theme.itemSizeLarge

    SilicaItem {
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        anchors {
            verticalCenter: parent.verticalCenter
        }
        Avatar {
            jid: root.jid
            name: root.displayName
            smooth: true;
            onClicked: root.avatarAction.clicked()

            MouseArea {
                anchors.fill: parent
                Button {
                    id: avatarActionHoverImage
                    icon.source: root.avatarAction.icon.source
                    width: parent.width / 2
                    height: width
                    anchors.centerIn: parent
                    visible:  root.avatarAction.enabled
                }
            }
        }
    }

    Row {
        id: displayNameArea
        height: Theme.iconSizeMedium

        width: parent.width - Theme.iconSizeMedium - Theme.paddingSmall
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingSmall

        IconButton {
            id: displayNameEditingButton
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "image://theme/icon-m-edit"
            width: Theme.iconSizeMedium
            onClicked: {
                if (displayNameText.visible) {
                    displayNameTextField.visible = true
                    displayNameText.visible = false
                    displayNameTextField.forceActiveFocus()
                    displayNameTextField.selectAll()
                } else {
                    displayNameTextField.visible = false
                    displayNameText.visible = true

                    if (displayNameTextField.text !== root.displayName) {
                        root.changeDisplayName(displayNameTextField.text)
                    }
                }
            }
        }

        Label {
            id: displayNameText
            text: root.displayName
            textFormat: Text.PlainText
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeLarge
            maximumLineCount: 1
            elide: Text.ElideRight
            visible: !displayNameTextField.visible
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.iconSizeMedium - Theme.paddingSmall
            // TODO: Get update of current vCard by using Entity Capabilities
                onTextChanged: handleDisplayNameChanged()

            MouseArea {
                anchors.fill: parent
                onClicked: displayNameEditingButton.clicked()
            }
        }

        TextField {
            id: displayNameTextField
            text: displayNameText.text
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeLarge
            font.underline: false
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: displayNameText.top
            anchors.verticalCenterOffset:  displayNameTextField.textVerticalCenterOffset + 10
            width: parent.width - Theme.iconSizeMedium - Theme.paddingSmall
            visible: false
        }
    }
    Label {
        id: jidLabel
        anchors.bottom: parent.bottom
        width: parent.width - Theme.iconSizeMedium - Theme.paddingSmall - 2*Theme.horizontalPageMargin
        text: root.jid
        color: Theme.secondaryColor
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeTiny
        maximumLineCount: 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
    }
}

