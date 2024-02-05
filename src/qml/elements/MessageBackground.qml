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
    property color color: message.isOwn ? Theme.highlightColor: Theme.primaryColor
    property int tailSize: Theme.paddingLarge
	property bool showTail: true
	property alias dummy: dummy
	readonly property alias metaInfoWidth: metaInfo.width
    property bool refreshDate : false;

    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: {
            refreshDate = !refreshDate;
        }
    }

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
        spacing: Theme.paddingSmall
		anchors {
			bottom: parent.bottom
//			right: mainBG.right
            right: message.isOwn ? parent.right : undefined
            left: message.isOwn ? undefined : parent.left
//          margins: Theme.paddingSmall
		}

        // warning for different encryption corner cases
//        ScalableText {
        Label {
            text:
            {
                if (backgroundRoot.message.encryption === Encryption.NoEncryption) {
                    if (MessageModel.isOmemoEncryptionEnabled) {
                        // Encryption is set for the current chat but this message is unencrypted.
                        return qsTr("Unencrypted")
                    }
                } else if (MessageModel.encryption !== Encryption.NoEncryption && !backgroundRoot.message.isTrusted){
                    // Encryption is set for the current chat but the key of this message's sender
                    // is not trusted.
                    return qsTr("Untrusted")
                }

                return ""
            }
            visible: text.length
            color: isOwn ? Theme.highlightColor: Theme.primaryColor
//          color: Kirigami.Theme.neutralTextColor
//			scaleFactor: 0.9
            font.italic: true
            font.pixelSize: Theme.fontSizeTiny
        }

//      ScalableText {
        Label {
            text: backgroundRoot.message.errorText
            visible: text.length
            color: isOwn ? Theme.highlightColor: Theme.primaryColor
            font.pixelSize: Theme.fontSizeTiny
        }

//      ScalableText {
        Label {
            id: timestamp
            font.pixelSize: Theme.fontSizeTiny
            text: backgroundRoot.message.time
//          color: Kirigami.Theme.negativeTextColor
//			scaleFactor: 0.9
        }

//      Kirigami.Icon {
        Icon {
            source: "image://theme/icon-s-outline-secure"
            visible: backgroundRoot.message.encryption !== Encryption.NoEncryption
            width: Theme.iconSizeExtraSmall
            height: width
            anchors.bottom: timestamp.bottom
//          Layout.preferredWidth: Kirigami.Units.iconSizes.small
//          Layout.preferredHeight: Layout.preferredWidth
        }

//      Kirigami.Icon {
        Icon {
            // TODO: Use "security-low-symbolic" for distrusted, "security-medium-symbolic" for automatically trusted and "security-high-symbolic" for authenticated
            source: backgroundRoot.message.isTrusted ? "image://theme/icon-m-vpn" : "image://theme/icon-s-warning"
            visible: backgroundRoot.message.encryption !== Encryption.NoEncryption
            width: Theme.iconSizeExtraSmall
            height: width
            anchors.bottom: timestamp.bottom
//          Layout.preferredWidth: Kirigami.Units.iconSizes.small
//          Layout.preferredHeight: Layout.preferredWidth
        }

		Image {
			visible: message.isOwn
            source: deliveryStateIcon
            width: Theme.iconSizeExtraSmall
            height: width
            anchors.bottom: timestamp.bottom
        }

        Icon {
            source: "image://theme/icon-s-edit"
            visible: message.edited
            width: Theme.iconSizeExtraSmall
            height: width
            anchors.bottom: timestamp.bottom
        }
    }

    Label {
        id: dummy
        text: "⠀"
    }
}
