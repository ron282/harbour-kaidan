// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
// import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

import "../elements"

Row {
	id: root

	default property alias __data: mainArea.data
    property DockedPanel sheet
	property string jid
	property string displayName
    property Button avatarAction

    anchors.topMargin:  0
    anchors.bottomMargin: 0
    anchors.leftMargin: Theme.paddingLarge* 2
    anchors.rightMargin: anchors.leftMargin

	Avatar {
		jid: root.jid
		name: root.displayName
        //FIXME Layout.preferredHeight: Kirigami.Units.gridUnit * 8
        //FIXME Layout.preferredWidth: Layout.preferredHeight

		// TODO: Make icon also visible when the cursor is on it directly after opening this page
	}

	Column {
		id: mainArea
        anchors.leftMargin: 15

		Row {
			id: displayNameArea
			spacing: 0

			Button {
				id: displayNameEditingIcon
                //FIXME Controls.ToolTip.text: qsTr("Change name…")
                icon.source: "image://theme/icon-m-edit"
				onHoveredChanged: {
					if (hovered) {
						flat = false
					} else {
						flat = true
					}
				}
				onClicked: {
					if (displayNameText.visible) {
						displayNameTextField.visible = true
						displayNameTextField.forceActiveFocus()
						displayNameTextField.selectAll()
					} else {
						displayNameTextField.visible = false
						displayNameArea.changeDisplayName(displayNameTextField.text)
					}
				}
			}

            SectionHeader {
				id: displayNameText
				text: root.displayName
				textFormat: Text.PlainText
				maximumLineCount: 1
				elide: Text.ElideRight
				visible: !displayNameTextField.visible
                //FIXME // Layout.alignment: Qt.AlignVCenter
				width: parent.width
                leftPadding: Theme.paddingLarge
				// TODO: Get update of current vCard by using Entity Capabilities
				onTextChanged: displayNameChangedFunction()

				MouseArea {
					anchors.fill: displayNameText
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onEntered: displayNameEditingIcon.flat = false
					onExited: displayNameEditingIcon.flat = true
					onClicked: displayNameEditingIcon.clicked(Qt.LeftButton)
				}
			}

            TextField {
				id: displayNameTextField
				text: displayNameText.text
				visible: false
                anchors.leftMargin: Theme.paddingLarge
				width: parent.width
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
            anchors.leftMargin: displayNameTextField.anchors.leftMargin
		}
	}
}
