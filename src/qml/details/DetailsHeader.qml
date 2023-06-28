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

	anchors.topMargin: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.largeSpacing * 2
    anchors.bottomMargin: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.largeSpacing
    anchors.leftMargin: Kirigami.Units.largeSpacing * 2
    anchors.rightMargin: anchors.leftMargin

	Avatar {
		jid: root.jid
		name: root.displayName
        //FIXME Layout.preferredHeight: Kirigami.Units.gridUnit * 8
        //FIXME Layout.preferredWidth: Layout.preferredHeight

		// TODO: Make icon also visible when the cursor is on it directly after opening this page
		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			visible: avatarAction.enabled
			onEntered: {
				avatarActionHoverImage.visible = true
				avatarHoverFadeInAnimation.start()
			}
			onExited: avatarHoverFadeOutAnimation.start()
			onClicked: root.avatarAction.triggered()

            Icon {
				id: avatarActionHoverImage
				source: root.avatarAction.icon.name
				color: Kirigami.Theme.backgroundColor
				width: parent.width / 2
				height: width
				anchors.centerIn: parent
				opacity: 0
				visible: false

				NumberAnimation on opacity {
					id: avatarHoverFadeInAnimation
					from: 0
					to: 0.8
					duration: 250
				}

				NumberAnimation on opacity {
					id: avatarHoverFadeOutAnimation
					from: 0.8
					to: 0
					duration: 250
				}
			}
		}
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
                //FIXME display: Controls.AbstractButton.IconOnly
                //FIXME checked: !displayNameText.visible
                //FIXME flat: true
                //FIXME Layout.preferredWidth: Layout.preferredHeight
                //FIXME Layout.preferredHeight: displayNameTextField.implicitHeight
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
				leftPadding: Kirigami.Units.largeSpacing
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
                anchors.leftMargin: Kirigami.Units.largeSpacing
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
			color: Kirigami.Theme.secondaryColor
			textFormat: Text.PlainText
			maximumLineCount: 1
			elide: Text.ElideRight
			width: parent.width
            anchors.leftMargin: displayNameEditingIcon.Layout.preferredWidth + displayNameTextField.anchors.leftMargin
		}
	}
}
