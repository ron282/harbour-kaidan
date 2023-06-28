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
	property alias bodyLabel: bodyLabel
	property var files;
	property var reactions

	property bool isGroupBegin: {
		return modelIndex < 1 ||
			MessageModel.data(MessageModel.index(modelIndex - 1, 0), MessageModel.Sender) !== senderJid
	}

	signal messageEditRequested(string id, string body)
	signal quoteRequested(string body)

	height: messageArea.implicitHeight + (isGroupBegin ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing)

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

    Column {
		id: messageArea
		spacing: -5

        Row {
			// Own messages are on the right, others on the left side.
			layoutDirection: isOwn ? Qt.RightToLeft : Qt.LeftToRight

			// placeholder
//			Item {
//				//FIXME Layout.preferredWidth: 5
//			}

			Item {
				visible: !isOwn
                anchors.horizontalCenter: parent.horizontalCenter

				Avatar {
					id: avatar
					visible: !isOwn && isGroupBegin
					anchors.fill: parent
					jid: root.senderJid
					name: root.senderName
				}
			}

			// message bubble
            BackgroundItem {
				id: bubble

				readonly property string paddingText: {
					"⠀".repeat(Math.ceil(background.metaInfoWidth / background.dummy.implicitWidth))
				}

				readonly property alias backgroundColor: bubbleBackground.color

                MessageBackground {
					id: bubbleBackground
					message: root
					showTail: !isOwn && isGroupBegin

					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.LeftButton | Qt.RightButton

						onClicked: {
							if (mouse.button === Qt.RightButton)
								showContextMenu()
						}

						onPressAndHold: showContextMenu()
					}
				}

                Column {
					id: content

                    Row {
						id: spoilerHintRow
						visible: isSpoiler

                        Label {
							text: spoilerHint == "" ? qsTr("Spoiler") : spoilerHint
							color: Kirigami.Theme.textColor
							font.pixelSize: Kirigami.Units.gridUnit * 0.8
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

						Item {
                            width: parent.width
							height: 1
						}

                        Icon {
							height: 28
							width: 28
							source: isShowingSpoiler ? "password-show-off" : "password-show-on"
							color: Kirigami.Theme.textColor
						}
					}
                    Separator {
						visible: isSpoiler
                        width:  parent.width
						color: {
                            bgColor = Kirigami.Theme.backgroundColor
                            textColor = Kirigami.Theme.textColor
							return Qt.tint(textColor, Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.7))
						}
					}

                    Column {
						visible: isSpoiler && isShowingSpoiler || !isSpoiler

                        Button {
							visible: {
								switch (root.mediaType) {
								case Enums.MessageType.MessageUnknown:
								case Enums.MessageType.MessageText:
								case Enums.MessageType.MessageGeoLocation:
									break
								case Enums.MessageType.MessageImage:
								case Enums.MessageType.MessageAudio:
								case Enums.MessageType.MessageVideo:
								case Enums.MessageType.MessageFile:
								case Enums.MessageType.MessageDocument:
									return !transferWatcher.isLoading && root.mediaGetUrl !== ""
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
							text: Utils.formatMessage(messageBody) + bubble.paddingText
							textFormat: Text.StyledText
							wrapMode: Text.Wrap
                            color: Theme.textColor
							onLinkActivated: Qt.openUrlExternally(link)
						}
                        Separator {
							visible: isSpoiler && isShowingSpoiler
                            width : parent.width
							color: {
                                bgColor = Theme.backgroundColor
                                textColor = Theme.textColor
								return Qt.tint(textColor, Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.7))
							}
						}
					}

					// message reactions (emojis in reaction to this message)
					Flow {
						spacing: 4
                        anchors.rightMargin: isOwn ? 45 : 30
                        width: {
							if (messageReactionAddition.visible) {
								return (messageReactionAddition.width + spacing) * (Object.keys(root.reactions).length + 1)
							} else {
								return (messageReactionAddition.width + spacing) * Object.keys(root.reactions).length
							}
						}

/*						ColumnView {
							model: Object.keys(root.reactions)

							MessageReactionDisplay {
								messageId: root.msgId
								emoji: modelData
								isOwnMessage: root.isOwn
								senderJids: root.reactions[modelData]
								senderSheet: root.reactionSenderSheet
								primaryColor: root.isOwn ? primaryBackgroundColor : secondaryBackgroundColor
								accentColor: bubble.backgroundColor
							}
						}
*/

						MessageReactionAddition {
							id: messageReactionAddition
							// TODO: Remove " && Kaidan.connectionState === Enums.StateConnected" once offline queue for message reactions is implemented
							visible: !root.isOwn && Object.keys(root.reactions).length && Kaidan.connectionState === Enums.StateConnected
							messageId: root.msgId
							emojiPicker: root.reactionEmojiPicker
							primaryColor: secondaryBackgroundColor
							accentColor: bubble.backgroundColor
						}
					}

					// warning for different encryption corner cases
					CenteredAdaptiveText {
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

						visible: text.length
                        color: Theme.negativeTextColor
						font.italic: true
						scaleFactor: 0.9
                        anchors.bottomMargin: 10
					}

                    Label {
						visible: errorText
						id: errorLabel
						text: qsTr(errorText)
                        color: Theme.secondaryColor
                        font.pixelSize: 20 * 0.8
					}
				}
			}

			// placeholder
			Item {
                width: parent.width
			}
		}

		// Read marker text for own message
		Text {
			visible: isLastRead
			text: qsTr("%1 has read up to this point").arg(chatName)
            anchors.topMargin: 10
            anchors.leftMargin: 10
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
