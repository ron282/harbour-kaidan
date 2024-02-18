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

import QtQuick 2.5
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
	property string senderId
	property string senderName
	property string chatName
    property bool isOwn: true
	property int encryption
	property bool isTrusted
	property string messageBody
	property string date
	property string time
	property int deliveryState
	property string deliveryStateName
	property url deliveryStateIcon
	property bool isLastRead
	property bool edited
	property bool isSpoiler
	property string spoilerHint
	property bool isShowingSpoiler: false
	property string errorText: ""
    property string downloadUrl
    property string localFilePath
    property int nbfiles : 0
    property alias bodyLabel: bodyLabel
	property var files;
	property var displayedReactions
	property var detailedReactions
	property var ownDetailedReactions

	property bool isGroupBegin: {
		return modelIndex < 1 ||
			MessageModel.data(MessageModel.index(modelIndex - 1, 0), MessageModel.SenderId) !== senderId
	}

	signal messageEditRequested(string replaceId, string body, string spoilerHint)
	signal quoteRequested(string body)

    contentHeight: messageArea.height + (isGroupBegin ? Theme.paddingLarge : Theme.paddingSmall)
//  alwaysVisibleActions: false

    menu: contextMenu

/*	actions: [
		// TODO: Move message to the left when action is displayed and message is too large or
		// display all actions at the bottom / at the top of the message bubble
		Button {
			text: "Add message reaction"
			icon.name: "smiley-add"
			visible: !root.displayedReactions.length
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
            width: isOwn ? root.width - Theme.iconSizeMedium - Theme.paddingMedium : root.width - Theme.paddingMedium

            Item {
                id: avatarItem
                visible: !isOwn
                anchors.top: parent.top
                height: Theme.iconSizeMedium
                width: isOwn ? 0 : Theme.iconSizeMedium
				Avatar {
					id: avatar
                    visible: !isOwn /*&& isGroupBegin*/
					anchors.fill: parent
					jid: root.senderId
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

                readonly property alias backgroundColor: bubbleBackground.color

                MessageBackground {
                    id: bubbleBackground
                    message: root
                    showTail: !isOwn && isGroupBegin
                    anchors.fill: parent

                    onPressAndHold: showContextMenu()

                    Column {
					id: content
                    width: parent.width

                    Row {
						id: spoilerHintRow
						visible: isSpoiler
                        spacing: Theme.paddingSmall
                        height: Math.max(Theme.iconSizeSmall, spoilerLabel.height)

                        Label {
                            id: spoilerLabel
							text: spoilerHint == "" ? qsTr("Spoiler") : spoilerHint
                            color: isOwn ? Theme.highlightColor: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeMedium
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: {
    //									if (mouse.button === Qt.LeftButton) {
                                        isShowingSpoiler = !isShowingSpoiler
    //									}
                                }
                            }
                        }

                        Icon {
                            height: Theme.iconSizeSmall
                            width: height
                            color: isOwn ? Theme.highlightColor: Theme.primaryColor
                            source: isShowingSpoiler ? "image://theme/icon-splus-hide-password" : "image://theme/icon-splus-show-password"
//						onPressAndHold: showContextMenu()
//					}
//				}

//				contentItem: ColumnLayout {
//					// spoiler hint area
//					ColumnLayout {
//						visible: isSpoiler
//						Layout.minimumWidth: bubbleBackground.metaInfoWidth
//						Layout.bottomMargin: isShowingSpoiler ? 0 : Kirigami.Units.largeSpacing * 2

//						RowLayout {
//							Controls.Label {
//								text: spoilerHint == "" ? qsTr("Spoiler") : Utils.formatMessage(spoilerHint)
//								textFormat: Text.StyledText
//								wrapMode: Text.Wrap
//								color: Kirigami.Theme.textColor
//								Layout.fillWidth: true
//							}

//							ClickableIcon {
//								source: isShowingSpoiler ? "password-show-off" : "password-show-on"
//								Layout.leftMargin: Kirigami.Units.largeSpacing
//								onClicked: isShowingSpoiler = !isShowingSpoiler
//							}
						}
                    }

                    Separator {
						visible: isSpoiler
                        width:  parent.width
                    }

                    Button {
                        id: downloadMedia

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

                    Column {
                       visible: isSpoiler && isShowingSpoiler || !isSpoiler
                       width: parent.width

                       Repeater {
                            model: root.files
                            width: Screen.width /2
                            height: width

                            delegate:
                                MediaPreviewOther {

//                                  property var modelData

                                    messageId: root.msgId

                                    mediaSource: {
                                        if (modelData.localFilePath) {
                                            var local = MediaUtilsInstance.fromLocalFile(modelData.localFilePath);
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
                           linkColor: color
                           anchors.right : isOwn ? parent.right : undefined
                           width: isOwn ? parent.width - Theme.paddingMedium : parent.width - Theme.paddingMedium - Theme.iconSizeMedium
                           onLinkActivated: Qt.openUrlExternally(link)
                       }

                       Separator {
                           visible: isSpoiler && isShowingSpoiler
                           width : parent.width
                       }
                    }
//						Kirigami.Separator {
//							visible: isShowingSpoiler
//							Layout.fillWidth: true
//							color: {
//								const bgColor = Kirigami.Theme.backgroundColor
//								const textColor = Kirigami.Theme.textColor
//								return Qt.tint(textColor, Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.7))
//							}
//						}
//					}

//					ColumnLayout {
//						visible: isSpoiler && isShowingSpoiler || !isSpoiler

//						Repeater {
//							model: root.files

//							Layout.preferredWidth: 200
//							Layout.preferredHeight: 200

//							delegate: MediaPreviewOther {
//								required property var modelData

//								messageId: root.msgId

//								mediaSource: {
//									if (modelData.localFilePath) {
//										let local = MediaUtilsInstance.fromLocalFile(modelData.localFilePath);
//										if (MediaUtilsInstance.localFileAvailable(local)) {
//											return local;
//										}
//									}
//									return "";
//								}
//								message: root
//								file: modelData
//							}
//						}

//						// message body
//						Controls.Label {
//							id: bodyLabel
//							visible: messageBody
//							text: Utils.formatMessage(messageBody) + bubble.paddingText
//							textFormat: Text.StyledText
//							wrapMode: Text.Wrap
//							color: Kirigami.Theme.textColor
//							onLinkActivated: Qt.openUrlExternally(link)
//							Layout.maximumWidth: root.width - Kirigami.Units.gridUnit * 6
//						}
//					}

					// message reactions (emojis in reaction to this message)

                    Flow {
                        visible: displayedReactionsArea.count
                        spacing: 4
                        width: {
                            var displayedReactionsWidth = 0

                            for (var i = 0; i < displayedReactionsArea.count; i++) {
                                displayedReactionsWidth += displayedReactionsArea.itemAt(i).width
                            }

                            return displayedReactionsWidth + (messageReactionAdditionButton.width * 2) + spacing * (displayedReactionsArea.count + 2)
                        }

                        Repeater {
                            id: displayedReactionsArea
                            model: root.displayedReactions

                            MessageReactionDisplayButton {
                                accentColor: bubble.backgroundColor
                                ownReactionIncluded: modelData.ownReactionIncluded
                                deliveryState: modelData.deliveryState
                                isOwnMessage: root.isOwn
                                text: modelData.count === 1 ? modelData.emoji : modelData.emoji + " " + modelData.count
                                width: smallButtonWidth + (text.length < 3 ? 0 : (text.length - 2) * Kirigami.Theme.defaultFont.pixelSize * 0.6)
                                onClicked: {
                                    if (ownReactionIncluded) {
                                        if (deliveryState === MessageReactionDeliveryState.PendingRemovalAfterSent ||
                                            deliveryState === MessageReactionDeliveryState.PendingRemovalAfterDelivered) {
                                            MessageModel.addMessageReaction(root.msgId, modelData.emoji)
                                        } else {
                                            MessageModel.removeMessageReaction(root.msgId, modelData.emoji)
                                        }
                                    } else {
                                        MessageModel.addMessageReaction(root.msgId, modelData.emoji)
                                    }
                                }
                            }
                        }

                        MessageReactionAdditionButton {
                            id: messageReactionAdditionButton
                            messageId: root.msgId
                            emojiPicker: root.reactionEmojiPicker
                            accentColor: bubble.backgroundColor
                        }

                        MessageReactionDetailsButton {
                            messageId: root.msgId
                            accentColor: bubble.backgroundColor
                            isOwnMessage: root.isOwn
                            detailedReactions: root.detailedReactions
                            ownDetailedReactions: root.ownDetailedReactions
                            detailsSheet: root.reactionDetailsSheet
                        }
                    }
                    Label {
                        text: " "
                        font.pixelSize: Theme.fontSizeTiny
                    }
//						Repeater {
//							id: displayedReactionsArea
//							model: root.displayedReactions

//							MessageReactionDisplayButton {
//								accentColor: bubble.backgroundColor
//								ownReactionIncluded: modelData.ownReactionIncluded
//								deliveryState: modelData.deliveryState
//								isOwnMessage: root.isOwn
//								text: modelData.count === 1 ? modelData.emoji : modelData.emoji + " " + modelData.count
//								width: smallButtonWidth + (text.length < 3 ? 0 : (text.length - 2) * Kirigami.Theme.defaultFont.pixelSize * 0.6)
//								onClicked: {
//									if (ownReactionIncluded &&
//										deliveryState !== MessageReactionDeliveryState.PendingRemovalAfterSent &&
//										deliveryState !== MessageReactionDeliveryState.PendingRemovalAfterDelivered) {
//										MessageModel.removeMessageReaction(root.msgId, modelData.emoji)
//									} else {
//										MessageModel.addMessageReaction(root.msgId, modelData.emoji)
//									}
//								}
//							}
//						}

//						MessageReactionAdditionButton {
//							id: messageReactionAdditionButton
//							messageId: root.msgId
//							emojiPicker: root.reactionEmojiPicker
//							accentColor: bubble.backgroundColor
//						}

//						MessageReactionDetailsButton {
//							messageId: root.msgId
//							accentColor: bubble.backgroundColor
//							isOwnMessage: root.isOwn
//							detailedReactions: root.detailedReactions
//							ownDetailedReactions: root.ownDetailedReactions
//							detailsSheet: root.reactionDetailsSheet
//						}
//					}
//>>>>>>> master
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
            visible: root.isLastRead && MessageModel.currentAccountJid !== MessageModel.currentChatJid
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
            contextMenu.message = root
            openMenu()
        }
    }
//=======
//			Item {
//				Layout.fillWidth: true
//			}
//		}

//		// Read marker text for own message
//		RowLayout {
//			visible: root.isLastRead && MessageModel.currentAccountJid !== MessageModel.currentChatJid
//			spacing: Kirigami.Units.smallSpacing * 3
//			Layout.topMargin: spacing
//			Layout.leftMargin: spacing
//			Layout.rightMargin: spacing

//			Kirigami.Separator {
//				opacity: 0.8
//				Layout.fillWidth: true
//			}

//			ScalableText {
//				text: qsTr("%1 has read up to this point").arg(chatName)
//				color: Kirigami.Theme.disabledTextColor
//				scaleFactor: 0.9
//				elide: Text.ElideMiddle
//				Layout.maximumWidth: parent.width - Kirigami.Units.largeSpacing * 10
//			}

//			Kirigami.Separator {
//				opacity: 0.8
//				Layout.fillWidth: true
//			}
//		}
//	}

//	/**
//	 * Shows a context menu (if available) for this message.
//	 *
//	 * That is especially the case when this message is an element of the ChatPage.
//	 */
//	function showContextMenu() {
//		if (contextMenu) {
//			contextMenu.file = null
//			contextMenu.message = this
//			contextMenu.popup()
//		}
//	}
//>>>>>>> master
}
