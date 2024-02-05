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
                    sourceSize.height: Theme.iconSizeSmallPlus
                    sourceSize.width: Theme.iconSizeSmallPlus
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
            icon.sourceSize.width: Theme.iconSizeSmallPlus
            icon.sourceSize.height: Theme.iconSizeSmallPlus
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
//=======
//GridLayout {
//	id: root

//	default property alias __data: mainArea.data
//	required property string jid
//	required property string displayName
//	required property Kirigami.Action avatarAction

//	flow: width > Kirigami.Units.gridUnit * 20 ? GridLayout.LeftToRight : GridLayout.TopToBottom
//	Layout.topMargin: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.largeSpacing * 2
//	Layout.bottomMargin: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.largeSpacing
//	Layout.leftMargin: Kirigami.Units.largeSpacing * 2
//	Layout.rightMargin: Layout.leftMargin

//	Avatar {
//		id: avatar
//		jid: root.jid
//		name: root.displayName
//		Layout.alignment: Qt.AlignHCenter
//		Layout.preferredHeight: Kirigami.Units.gridUnit * 8
//		Layout.preferredWidth: Layout.preferredHeight

//		MouseArea {
//			anchors.fill: parent
//			cursorShape: Qt.PointingHandCursor
//			visible: avatarAction.enabled
//			hoverEnabled: true
//			onHoveredChanged: {
//				if (containsMouse) {
//					avatarHoverFadeInAnimation.start()
//				} else {
//					avatarHoverFadeOutAnimation.start()
//				}
//			}
//			onExited: avatarHoverFadeOutAnimation.start()
//			onClicked: root.avatarAction.triggered()

//			Rectangle {
//				anchors.fill: parent
//				color: Kirigami.Theme.backgroundColor
//				opacity: avatar.source.toString().length ? avatarActionHoverImage.opacity * 0.5 : 0
//			}

//			Kirigami.Icon {
//				id: avatarActionHoverImage
//				source: root.avatarAction.icon.name
//				color: Kirigami.Theme.textColor
//				width: parent.width / 2
//				height: width
//				anchors.centerIn: parent

//				NumberAnimation on opacity {
//					id: avatarHoverFadeOutAnimation
//					from: avatar.source.toString().length? 1 : 0.8
//					to: 0
//					duration: 250
//				}

//				NumberAnimation on opacity {
//					id: avatarHoverFadeInAnimation
//					from: 0
//					to: avatar.source.toString().length ? 1 : 0.8
//					duration: 250
//				}
//			}
//		}
//	}

//	ColumnLayout {
//		id: mainArea
//		Layout.leftMargin: 15

//		RowLayout {
//			id: displayNameArea
//			spacing: 0

//			Button {
//				id: displayNameEditingButton
//				text: qsTr("Change name…")
//				icon.name: "document-edit-symbolic"
//				display: Controls.AbstractButton.IconOnly
//				checked: !displayNameText.visible
//				flat: !hovered && !displayNameMouseArea.containsMouse
//				Controls.ToolTip.text: text
//				Layout.preferredWidth: Layout.preferredHeight
//				Layout.preferredHeight: displayNameTextField.implicitHeight
//				onClicked: {
//					if (displayNameText.visible) {
//						displayNameTextField.visible = true
//						displayNameTextField.forceActiveFocus()
//						displayNameTextField.selectAll()
//					} else {
//						displayNameTextField.visible = false

//						if (displayNameTextField.text !== root.displayName) {
//							root.changeDisplayName(displayNameTextField.text)
//						}
//					}
//				}
//			}

//			Kirigami.Heading {
//				id: displayNameText
//				text: root.displayName
//				textFormat: Text.PlainText
//				maximumLineCount: 1
//				elide: Text.ElideRight
//				visible: !displayNameTextField.visible
//				Layout.alignment: Qt.AlignVCenter
//				Layout.fillWidth: true
//				leftPadding: Kirigami.Units.largeSpacing
//				// TODO: Get update of current vCard by using Entity Capabilities
//				onTextChanged: handleDisplayNameChanged()

//				MouseArea {
//					id: displayNameMouseArea
//					anchors.fill: displayNameText
//					hoverEnabled: true
//					cursorShape: Qt.PointingHandCursor
//					onClicked: displayNameEditingButton.clicked()
//				}
//			}

//			Controls.TextField {
//				id: displayNameTextField
//				text: displayNameText.text
//				visible: false
//				Layout.leftMargin: Kirigami.Units.largeSpacing
//				Layout.fillWidth: true
//				onAccepted: displayNameEditingButton.clicked()
//			}
//		}

//		Controls.Label {
//			text: root.jid
//			color: Kirigami.Theme.disabledTextColor
//			textFormat: Text.PlainText
//			maximumLineCount: 1
//			elide: Text.ElideRight
//			Layout.fillWidth: true
//			Layout.leftMargin: displayNameEditingButton.Layout.preferredWidth + displayNameTextField.Layout.leftMargin
//		}
//	}
//>>>>>>> master
}

