// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"

Column {
    id: root
    width: parent.width
    height: Theme.itemSizeMedium + Theme.iconSizeExtraLarge + Theme.itemSizeMedium + Theme.itemSizeSmall
    spacing: 0

    property string jid
    property string displayName
    property Button avatarAction


    //    default property alias __data: mainArea.data

    PageHeader {
        title: root.displayName
    }

    BackgroundItem {
 //       y: Theme.itemSizeMedium
        height: Theme.iconSizeExtraLarge
        width: Theme.iconSizeExtraLarge
        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: -Theme.iconSizeMedium + Theme.horizontalPageMargin
        }
        Avatar {
            jid: root.jid
            name: root.displayName
            smooth: true;
            onClicked: root.avatarAction.clicked()

            MouseArea {
                anchors.fill: parent
                HighlightImage {
                    id: avatarActionHoverImage
                    source: root.avatarAction.icon.source
                    width: parent.width / 2
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    visible:  root.avatarAction.enabled
                }
            }
        }
    }

    Row {
        id: displayNameArea
        height: Math.max(displayNameText.height, displayNameTextField.height, displayNameEditingButton.height)
        width: parent.width
        spacing: 0

        Label {
            id: displayNameText
            text: root.displayName
            textFormat: Text.PlainText
            elide: Text.ElideRight
            visible: !displayNameTextField.visible
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.iconSizeMedium - Theme.horizontalPageMargin
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
            font.underline: false
            labelVisible: false
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: displayNameText.top
            anchors.verticalCenterOffset:  displayNameTextField.textVerticalCenterOffset
            width: parent.width - Theme.iconSizeMedium - Theme.horizontalPageMargin
            visible: false
        }

        IconButton {
            id: displayNameEditingButton
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "image://theme/icon-m-edit"
            height: Theme.iconSizeSmall
            width: height
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
    }
    Label {
        id: jidLabel
        width: parent.width - 2*Theme.horizontalPageMargin
        //FIXME
        //anchors.horizontalCenter: displayNameEditingButton.horizontalCenter
        text: root.jid
        color: Theme.secondaryColor
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
    }
}

