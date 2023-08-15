// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2022 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

/**
 * This is a pane for writing and sending chat messages.
 */
BackgroundItem {
	id: root
    width: parent.width

	property QtObject chatPage
	property alias messageArea: messageArea
	property int lastMessageLength: 0
    readonly property MessageComposition composition: MessageComposition {
		id: composition
		account: AccountManager.jid
		to: MessageModel.currentChatJid
		body: messageArea.text
        spoilerHint: spoilerHintField.text
		draftId: MessageModel.currentDraftMessageId

		onDraftFetched: {
			this.isSpoiler = isSpoiler;
			spoilerHintField.text = spoilerHint;
			messageArea.text = body;

			// Position the cursor after the draft message's body.
			messageArea.cursorPosition = messageArea.text.length
		}
    }

    Column {
        width: parent.width
		spacing: 0

        Row {
			visible: composition.isSpoiler
			spacing: 0
            width: parent.width
            height: Theme.iconSizeMedium

            TextArea {
				id: spoilerHintField
                width: parent.width - closeSpoilerIcon.width
				placeholderText: qsTr("Spoiler hint")
                wrapMode: TextEdit.Wrap
			}

            IconButton {
                id: closeSpoilerIcon
                //text: qsTr("Close spoiler hint field")
                icon.source: "image://theme/icon-m-close"
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium

				onClicked: {
					composition.isSpoiler = false
					spoilerHintField.text = ""
				}
			}
		}

        Separator {
			visible: composition.isSpoiler
            width: parent.width
            anchors.topMargin: Theme.paddingSmall
            anchors.bottomMargin: anchors.topMargin
		}

        Row {
			spacing: 0
            width: parent.width
            height: Theme.iconSizeMedium

			// emoji picker button
            ClickableIcon {
                id: emojiPickerIcon
                icon.source: "image://theme/icon-m-toy"
                enabled: sendButton.enabled
                onClicked: !emojiPicker.toggle()
			}

/*			EmojiPicker {
				id: emojiPicker
				x: - root.padding
				y: - height - root.padding
				textArea: messageArea
			}
*/
            TextArea {
				id: messageArea
				placeholderText: MessageModel.isOmemoEncryptionEnabled ? qsTr("Compose <b>encrypted</b> message") : qsTr("Compose <b>unencrypted</b> message")
				// background: Item {}
				wrapMode: TextEdit.Wrap
                width: getMessageAreaWidth(parent.width)

                function getMessageAreaWidth(w) {
                    if(emojiPickerIcon.visible) w = w - emojiPickerIcon.width;
                    if(shareIcon.visible) w = w - shareIcon.width;
                    if(voiceIcon.visible) w = w - voiceIcon.width;
                    if(sendButton.visible) w = w - sendButton.width;
                    return w;
                }

				state: "compose"

				onTextChanged: {
					handleShortcuts()

					// Skip events in which the text field was emptied (probably automatically after sending)
					if (text) {
						MessageModel.sendChatState(ChatState.Composing)
					} else {
						MessageModel.sendChatState(ChatState.Active)
					}
				}

				states: [
					State {
						name: "compose"
					},

					State {
						name: "edit"
					}
				]

				onStateChanged: {
					if (state === "edit") {
						// Move the cursor to the end of the text being corrected.
						forceActiveFocus()
						cursorPosition = text.length
					}
				}

				Keys.onReturnPressed: {
					if (event.key === Qt.Key_Return) {
						if (event.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)) {
							messageArea.append("")
						} else {
							sendMessage()
							event.accepted = true
						}
					}
				}

				Connections {
					target: chatPage.searchBar

					// Restore the active focus when searchBar is closed.
					function onActiveChanged() {
						if (!chatPage.searchBar.active) {
							root.forceActiveFocus()
						}
					}
				}

//				Connections {
//					target: chatPage.messageReactionEmojiPicker

					// Restore the active focus when messageReactionEmojiPicker is closed.
//					function onClosed() {
//						root.forceActiveFocus()
//					}
//				}
            }

            // Voice message button
            ClickableIcon {
                id: voiceIcon
                icon.source: MediaUtilsInstance.newMediaIconName(Enums.MessageAudio)
                visible: messageArea.text === ""
                width: Theme.iconSizeMedium
                Behavior on opacity {
                    NumberAnimation {}
                }
                onClicked: {
                    chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageAudio)
                }
			}

            // file sharing button
            ClickableIcon {
                id: shareIcon
                width: Theme.iconSizeMedium
                icon.source: "image://theme/icon-m-attach"

                visible: messageArea.text === ""
                Behavior on opacity {
                    NumberAnimation {}
                }

                property bool checked: false
                onClicked:
                {
                    if (!checked) {
                        mediaPopup.show()
                        checked = true
                    } else {
                        mediaPopup.hide()
                        checked = false
                    }
                }
            }

            DockedPanel {
                id: mediaPopup
                dock: Dock.Bottom
                width: parent.width
                height: Screen.height / 2

    //				x:  root.width - width - 40
    //				y: - height - root.padding - 20
    //				width: 470
    //                Column {
    //					anchors.fill: parent
    //                    AbstractApplicationHeader {
    //						width: parent.width
    //						leftPadding: Kirigami.Units.largeSpacing
    //						SectionHeader {
    //							text: qsTr("Attachments")
    //						}
    //					}

                SilicaFlickable {
                    Column {
                        PageHeader {
                            title: qsTr("Attachments")
                        }

                       width: parent.width
    //                   visible: thumbnails.count !== 0

                        ColumnView {
                            id: thumbnails
                            width: parent.width
                            itemHeight: Theme.itemSizeLarge
    //                            model: RecentPicturesModel {}

                            delegate: Item {
                                anchors.margins: Theme.smallSpacing

                                width: parent.width

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        chatPage.sendMediaSheet.openWithExistingFile(model.filePath)
                                        mediaPopup.close()
                                    }
                                }

                                Image {
                                    source: model.filePath
                                    height: 125
                                    width: 150
                                    sourceSize: "125x150"
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        height: Theme.iconSizeMedium
                        anchors.margins: 5

                        IconButton {
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            icon.source: "image://theme/icon-m-camera"
    //                                text: qsTr("Take picture")

                            onClicked: {
                                chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageImage)
                                mediaPopup.close()
                            }
                        }
                        IconButton {
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            icon.source: "image://theme/icon-m-video"
    //								title: qsTr("Record video")

                            onClicked: {
                                chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageVideo)
                                mediaPopup.close()
                            }
                        }
                        IconButton {
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            icon.source: "image://theme/icon-m-document"
    //                      title: qsTr("Share files")

                            onClicked: {
                                chatPage.sendMediaSheet.selectFile()
                                mediaPopup.close()
                            }
                        }
                        IconButton {
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            icon.source: "image://theme/icon-m-location"
    //				        title: qsTr("Share location")

                            onClicked: {
                                chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageGeoLocation)
                                mediaPopup.close()
                            }
                        }
                    }
                }
            } // DockedPanel

            ClickableIcon {
				id: sendButton
				visible: messageArea.text !== ""
                width: Theme.iconSizeMedium
                Behavior on opacity {
					NumberAnimation {}
				}
                icon.source: {
					if (messageArea.state === "compose")
                        return "image://theme/icon-m-send"
					else if (messageArea.state === "edit")
                        return "image://theme/icon-m-edit"
				}

				onClicked: sendMessage()
			}
        } // Row
    }

        /**
         * Forces the active focus on desktop devices.
         *
         * The focus is not forced on mobile devices because the soft keyboard would otherwise pop up.
         */
        function forceActiveFocus() {
        }

        /**
         * Sends the text entered in the messageArea.
         */
        function sendMessage() {
            // Do not send empty messages.
            if (!messageArea.text.length)
                return

            // Disable the button to prevent sending the same message several times.
            sendButton.enabled = false

            // Send the message.
            if (messageArea.state === "compose") {
                composition.send()
            } else if (messageArea.state === "edit") {
                MessageModel.correctMessage(chatPage.messageToCorrect, messageArea.text)
            }
            MessageModel.resetComposingChatState();

            clearMessageArea()

            // Enable the button again.
            sendButton.enabled = true

            // Show the cursor even if another element like the sendButton (after
            // clicking on it) was focused before.
            messageArea.forceActiveFocus()
        }

	/**
	 * Handles characters used for special actions.
	 */
	function handleShortcuts() {
        const currentCharacter = messageArea.text.substr(messageArea.cursorPosition - 1, 1)

		if (emojiPicker.isSearchActive()) {
			if (emojiPicker.searchedText === "" || currentCharacter === "" || currentCharacter === " ") {
				emojiPicker.close()
				return
			}

			// Handle the deletion or addition of characters.
			if (lastMessageLength >= messageArea.text.length)
				emojiPicker.searchedText = emojiPicker.searchedText.substr(0, emojiPicker.searchedText.length - 1)
			else
				emojiPicker.searchedText += currentCharacter

			emojiPicker.search()
		} else {
			if (currentCharacter === ":") {
				if (messageArea.cursorPosition !== 1) {
                    const predecessorOfCurrentCharacter = messageArea.text.substr(messageArea.cursorPosition - 2, 1)
					if (predecessorOfCurrentCharacter === " " || predecessorOfCurrentCharacter === "\n") {
						emojiPicker.openForSearch(currentCharacter)
						emojiPicker.search()
					}
				} else {
					emojiPicker.openForSearch(currentCharacter)
					emojiPicker.search()
				}
			}
		}

		lastMessageLength = messageArea.text.length
	}

	function clearMessageArea() {
		messageArea.text = ""
		spoilerHintField.text = ""
		chatPage.messageToCorrect = ''
		messageArea.state = "compose"
	}
}
