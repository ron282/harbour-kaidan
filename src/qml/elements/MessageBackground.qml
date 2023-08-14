// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// SPDX-FileCopyrightText: 2021 Jan Blackquill <uhhadd@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

BackgroundItem {
	id: backgroundRoot

	property QtObject message
//	property color color: message.isOwn ? rightMessageBubbleColor : primaryBackgroundColor
    property int tailSize: Theme.paddingLarge
	property bool showTail: true
	property alias dummy: dummy
	readonly property alias metaInfoWidth: metaInfo.width

	clip: true

/*	Item {
		id: tailBase
		clip: true
		visible: false

		anchors {
			top: parent.top
			bottom: parent.bottom
			left: parent.left
			leftMargin: -backgroundRoot.tailSize * 2
			rightMargin: -backgroundRoot.tailSize
			right: mainBG.left
		}
		Rectangle {
            color: backgroundRoot.color

			anchors.fill: parent
			anchors.topMargin: 4
			anchors.rightMargin: -backgroundRoot.tailSize
		}
	}
	Item {
		id: tailMask
		clip: true
		visible: false

		anchors {
			top: parent.top
			bottom: parent.bottom
			left: parent.left
			leftMargin: -backgroundRoot.tailSize * 2
			rightMargin: -backgroundRoot.tailSize
			right: mainBG.left
		}
        Rectangle {
			anchors.fill: parent
			anchors.rightMargin: backgroundRoot.tailSize

			width: backgroundRoot.tailSize * 3
//			color: "black"
		}
	}
	Rectangle {
		id: mainBG
		radius: roundedCornersRadius
		color: backgroundRoot.color
		anchors.fill: parent
		anchors.leftMargin: backgroundRoot.tailSize
	}
*/

    Row {
		id: metaInfo
		anchors {
			bottom: parent.bottom
//			right: mainBG.right
            right: message.isOwn ? parent.right : undefined
            left: message.isOwn ? undefined : parent.left
//          margins: Theme.paddingSmall
		}

        Label {
			id: timestamp
            //opacity: 0.5
            font.pixelSize: Theme.fontSizeTiny
			text: Qt.formatDateTime(message.dateTime, "hh:mm")

			MouseArea {
				id: timestampMouseArea
				anchors.fill: parent
			}

//			Controls.ToolTip {
//				visible: timestampMouseArea.containsMouse
//				text: Qt.formatDateTime(message.dateTime, "dd. MMM yyyy, hh:mm")
//				delay: 500
//			}
		}

        Icon {
            visible: backgroundRoot.message.encryption == Encryption.NoEncryption
            source: "image://theme/icon-s-outline-secure"
            width: Theme.iconSizeSmall
            height: width
		}

//        Icon {
//			// TODO: Use "security-low-symbolic" for distrusted, "security-medium-symbolic" for automatically trusted and "security-high-symbolic" for authenticated
//            source: backgroundRoot.message.isTrusted ? "image://theme/icon-s-installed" : "image://theme/icon-s-warning"
//			visible: backgroundRoot.message.encryption !== Encryption.NoEncryption
//            width: Theme.iconSizeSmall
//            height: width
//		}

		Image {
			visible: message.isOwn

			MouseArea {
				id: checkmarkMouseArea
				anchors.fill: parent
				hoverEnabled: true
			}

//			Controls.ToolTip {
//				text: message.deliveryStateName
//				visible: checkmarkMouseArea.containsMouse
//				delay: 500
//			}
		}
        Icon {
            source: "image://theme/icon-s-edit"
			visible: message.edited
//			// //FIXME Layout.preferredHeight: Kirigami.Units.gridUnit * 0.65
//			//FIXME Layout.preferredWidth: Kirigami.Units.gridUnit * 0.65
		}
	}

    Label {
        id: dummy
        text: "⠀"
    }
}
