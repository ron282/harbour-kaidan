// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"

PageHeader {
	id: root

	property string jid
	property string displayName

    title: displayName

//    property Button avatarAction

//    anchors.topMargin:  0
//    anchors.bottomMargin: 0
//    anchors.leftMargin: Theme.paddingLarge* 2
//    anchors.rightMargin: anchors.leftMargin


    SilicaItem {
        parent: root.extraContent
        height: Theme.iconSizeMedium
        anchors {
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        Avatar {
            id: avatar
            jid: chatItemWatcher.item.jid
            name: chatItemWatcher.item.displayName
            smooth: true;
            onClicked: pageStack.push(contactDetailsSheet)
        }
    }
    Rectangle {
            z: -1;
            color: "black";
            opacity: 0.35;
            anchors.fill: parent;
    }
}

/*    Row {
		id: mainArea
        parent: root.extraContent
        anchors.leftMargin: Theme.paddingMedium

        Avatar {
            jid: root.jid
            name: root.displayName

            // TODO: Make icon also visible when the cursor is on it directly after opening this page
        }

        Row {
			id: displayNameArea
			spacing: 0

            IconButton {
				id: displayNameEditingIcon
                icon.source: "image://theme/icon-s-edit"
				onClicked: {
					if (displayNameText.visible) {
						displayNameTextField.visible = true
						displayNameTextField.forceActiveFocus()
						displayNameTextField.selectAll()
					} else {
						displayNameTextField.visible = false

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
				maximumLineCount: 1
				elide: Text.ElideRight
				visible: !displayNameTextField.visible
                width: parent.width - displayNameEditingIcon.width
                leftPadding: Theme.paddingLarge
				// TODO: Get update of current vCard by using Entity Capabilities
				onTextChanged: handleDisplayNameChanged()

				MouseArea {
					anchors.fill: displayNameText
					onClicked: displayNameEditingIcon.clicked(Qt.LeftButton)
				}
			}

            TextField {
				id: displayNameTextField
				text: displayNameText.text
				visible: false
//                anchors.leftMargin: Theme.paddingLarge
                width: parent.width - displayNameEditingIcon.width
                //FIXME onAccepted: {
                //	displayNameArea.changeDisplayName(text)
                //	visible = false
                //}
			}

			function changeDisplayName(newDisplayName) {
				if (newDisplayName !== root.displayName) {
					root.displayNameChangeFunction(newDisplayName)
				}
			}
		}

        Label {
			text: root.jid
			textFormat: Text.PlainText
			maximumLineCount: 1
			elide: Text.ElideRight
            width: parent.width
//          anchors.leftMargin: displayNameTextField.anchors.leftMargin
		}
	}
}*/
