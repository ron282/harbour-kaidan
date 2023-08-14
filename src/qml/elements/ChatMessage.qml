// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2017 Ilya Bizyaev <bizyaev@zoho.com>
// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2019 Xavier <xavi@delape.net>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2019 caca hueto <cacahueto@olomono.de>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Yury Gubich <blue@macaw.me>
// SPDX-FileCopyrightText: 2022 Bhavy Airi <airiragahv@gmail.com>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0
import MediaUtils 0.1

ListItem {
	id: root

    property ContextMenu contextMenu
	property MessageReactionEmojiPicker reactionEmojiPicker
	property MessageReactionDetailsSheet reactionDetailsSheet

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
	property var displayedReactions
	property var detailedReactions
	property var ownDetailedReactions

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
<<<<<<< HEAD
			icon.source: "smiley-add"
			// TODO: Remove " && Kaidan.connectionState === Enums.StateConnected" once offline queue for message reactions is implemented
			visible: !root.isOwn && !Object.keys(root.reactions).length && Kaidan.connectionState === Enums.StateConnected
=======
			icon.name: "smiley-add"
			visible: !root.displayedReactions.length
>>>>>>> master
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

							return displayedReactionsWidth + (messageReactionAdditionButton.width * 2) + spacing * (displayedReactionsArea.count + 2)
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
