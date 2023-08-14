/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0
import MediaUtils 0.1

ListItem {
	id: root

    property ContextMenu contextMenu
	property MessageReactionEmojiPicker reactionEmojiPicker
	property MessageReactionSenderSheet reactionSenderSheet

	property int modelIndex
	property string msgId
	property string senderJid
	property string senderName
	property string chatName
    property bool isOwn: true
	property int encryption
	property bool isTrusted
	property string messageBody
	property date dateTime
	property int deliveryState
	property string deliveryStateName
	property url deliveryStateIcon
	property bool isLastRead
	property bool edited
	property bool isSpoiler
	property string spoilerHint
	property bool isShowingSpoiler: false
	property string errorText: ""
//	property alias bodyLabel: bodyLabel
	property var files;
	property var reactions

	property bool isGroupBegin: {
        return modelIndex < 1 ||
			MessageModel.data(MessageModel.index(modelIndex - 1, 0), MessageModel.Sender) !== senderJid
    }

	signal messageEditRequested(string id, string body)
	signal quoteRequested(string body)

    contentHeight: messageArea.height + (isGroupBegin ? Theme.paddingLarge : 0)
    menu: contextMenu

/*	actions: [
		// TODO: Move message to the left when action is displayed and message is too large or
		// display all actions at the bottom / at the top of the message bubble
		Button {
			text: "Add message reaction"
			icon.source: "smiley-add"
			// TODO: Remove " && Kaidan.connectionState === Enums.StateConnected" once offline queue for message reactions is implemented
			visible: !root.isOwn && !Object.keys(root.reactions).length && Kaidan.connectionState === Enums.StateConnected
			onTriggered: {
				root.reactionEmojiPicker.messageId = root.msgId
				root.reactionEmojiPicker.open()
			}
		}
	]
*/

    anchors {
        left: parent.left;
        right: parent.right;
//        margins: Theme.paddingSmall;
    }

    Rectangle {
        id: shadow
        color: "white"
//      radius: 3
        opacity: (!isOwn ? 0.05 : 0.15)
        antialiasing: true
        anchors {
            fill: messageArea
//            margins: -Theme.paddingSmall
        }
    }

    Column {
        id: messageArea
        // Own messages are on the right, others on the left side.
        anchors {
            left: (!isOwn ? parent.left : undefined)
            right: (isOwn ? parent.right : undefined)
            leftMargin: (!isOwn ? Theme.paddingSmall : undefined)
            rightMargin: (isOwn ? Theme.paddingSmall : undefined)
            verticalCenter: parent.verticalCenter
      }
        Row {
            // Own messages are on the right, others on the left side.
            layoutDirection: isOwn ? Qt.RightToLeft : Qt.LeftToRight
            spacing: Theme.paddingMedium
            width: root.width - Theme.iconSizeMedium - Theme.paddingMedium

            Item {
                id: avatarItem
                visible: !isOwn
//                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                anchors.top: parent.top
                height: Theme.iconSizeMedium
                width: isOwn ? 0 : Theme.iconSizeMedium
				Avatar {
					id: avatar
                    visible: !isOwn /*&& isGroupBegin*/
					anchors.fill: parent
					jid: root.senderJid
					name: root.senderName
				}
			}

            // message bubble
            BackgroundItem {
                id: bubble

                width: messageArea.width - avatarItem.width - Theme.paddingSmall
                height: content.height

//                readonly property string paddingText: {
//					"⠀".repeat(Math.ceil(background.metaInfoWidth / background.dummy.implicitWidth))
//				}

//                readonly property alias backgroundColor: bubbleBackground.color

                MessageBackground {
                    id: bubbleBackground
                    message: root
                    showTail: !isOwn && isGroupBegin
                    anchors.fill: parent

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (mouse.button === Qt.RightButton)
                                showContextMenu()
                        }

                        onPressAndHold: showContextMenu()
                    }
                }

                Column {
					id: content
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Row {
						id: spoilerHintRow
						visible: isSpoiler

                        Label {
                            id: spoilerLabel
							text: spoilerHint == "" ? qsTr("Spoiler") : spoilerHint
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeMedium
							MouseArea {
								anchors.fill: parent
								acceptedButtons: Qt.LeftButton | Qt.RightButton
								onClicked: {
									if (mouse.button === Qt.LeftButton) {
										isShowingSpoiler = !isShowingSpoiler
									}
								}
							}
						}

                        Icon {
                            height: Theme.iconSizeExtraSmall
                            width: height
                            source: isShowingSpoiler ? "image://theme/icon-splus-hide-password" : "image://theme/icon-splus-show-password"
						}
					}

                    Separator {
						visible: isSpoiler
                        width:  parent.width
                    }

                    Button {
                        visible: {
                            switch (root.mediaType) {
                            case Enums.MessageUnknown:
                            case Enums.MessageText:
                            case Enums.MessageGeoLocation:
                                break
                            case Enums.MessageImage:
                            case Enums.MessageAudio:
                            case Enums.MessageVideo:
                            case Enums.MessageFile:
                            case Enums.MessageDocument:
                                return (isSpoiler && isShowingSpoiler) || !isSpoiler &&
                                       !transferWatcher.isLoading && root.mediaGetUrl !== ""
                                       && (root.mediaLocation === "" || !MediaUtilsInstance.localFileAvailable(media.mediaSource))
                            }

                            return false
                        }
                        text: qsTr("Download")
                        onClicked: {
                            print("Downloading " + mediaGetUrl + "…")
                            Kaidan.client.downloadManager.startDownloadRequested(msgId, mediaGetUrl)
                        }
                    }

                    ColumnView {
                        model: root.files
                        itemHeight: Theme.itemSizeHuge
                        visible: {
                            console.log("MediaPreviewVisible=" + (isSpoiler && isShowingSpoiler) || !isSpoiler);
                            return (isSpoiler && isShowingSpoiler) || !isSpoiler;
                        }

                        delegate: MediaPreviewOther {
                            property var modelData

                            messageId: root.msgId

                            mediaSource: {
                                if (modelData.localFilePath) {
                                    local = MediaUtilsInstance.fromLocalFile(modelData.localFilePath);
                                    if (MediaUtilsInstance.localFileAvailable(local)) {
                                        return local;
                                    }
                                }
                                return "";
                            }
                            message: root
                            file: modelData
                        }
                    }

                    // message body
                    Label {
                        id: bodyLabel
                        visible: messageBody
                        text: Utils.formatMessage(messageBody) // + bubble.paddingText
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                        font.family: Theme.fontFamilyHeading
                        font.pixelSize: Theme.fontSizeMedium
                        color: isOwn ? Theme.highlightColor: Theme.primaryColor
                        anchors.right : isOwn ? parent.right : undefined
                        width: isOwn ? parent.width - Theme.paddingMedium : parent.width - Theme.paddingMedium - Theme.iconSizeMedium
                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                    Separator {
                        visible: isSpoiler && isShowingSpoiler
                        width : parent.width
                    }

					// message reactions (emojis in reaction to this message)

                    /*Flow {
						spacing: 4
                        anchors.rightMargin: isOwn ? 45 : 30
                        width: {
							if (messageReactionAddition.visible) {
								return (messageReactionAddition.width + spacing) * (Object.keys(root.reactions).length + 1)
							} else {
								return (messageReactionAddition.width + spacing) * Object.keys(root.reactions).length
							}
						}

                        ColumnView {
							model: Object.keys(root.reactions)

							MessageReactionDisplay {
								messageId: root.msgId
								emoji: modelData
								isOwnMessage: root.isOwn
								senderJids: root.reactions[modelData]
								senderSheet: root.reactionSenderSheet
//								primaryColor: root.isOwn ? primaryBackgroundColor : secondaryBackgroundColor
//								accentColor: bubble.backgroundColor
							}
						}
                        MessageReactionAddition {
							id: messageReactionAddition
							// TODO: Remove " && Kaidan.connectionState === Enums.StateConnected" once offline queue for message reactions is implemented
							visible: !root.isOwn && Object.keys(root.reactions).length && Kaidan.connectionState === Enums.StateConnected
							messageId: root.msgId
							emojiPicker: root.reactionEmojiPicker
							primaryColor: secondaryBackgroundColor
							accentColor: bubble.backgroundColor
						}
                    }*/

					// warning for different encryption corner cases
                    Label {
						text: {
							if (root.encryption === Encryption.NoEncryption) {
								if (MessageModel.isOmemoEncryptionEnabled) {
									// Encryption is set for the current chat but this message is
									// unencrypted.
									return qsTr("Unencrypted")
								}
							} else if (MessageModel.encryption !== Encryption.NoEncryption && !root.isTrusted){
								// Encryption is set for the current chat but the key of this message's
								// sender is not trusted.
								return qsTr("Untrusted")
							}

							return ""
						}

                        width: parent.width;
                        visible: text.length
                        color: isOwn ? Theme.highlightColor: Theme.primaryColor
                        font.italic: true
                        font.pixelSize: Theme.fontSizeTiny
                        anchors.bottomMargin: Theme.paddingSmall
                    }


                    Label {
						visible: errorText
						id: errorLabel
						text: qsTr(errorText)
                        width: parent.width;
                        color: isOwn ? Theme.highlightColor: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeTiny
                    }
                    Label {
                        text: " "
                        font.pixelSize: Theme.fontSizeTiny
                    }
				}
			}

			// placeholder
//			Item {
//                width: parent.width
//			}
        }
        // Read marker text for own message
        Text {
            id: isLastReadText
            visible: isLastRead
            color: Theme.primaryColor
            text: qsTr("%1 has read up to this point").arg(chatName)
            font.pixelSize: Theme.fontSizeTiny
        }
    }
    /**
     * Shows a context menu (if available) for this message.
     *
     * That is especially the case when this message is an element of the ChatPage.
     */
    function showContextMenu() {
        if (contextMenu) {
            contextMenu.file = null
            contextMenu.message = this
            contextMenu.popup()
        }
    }
}
