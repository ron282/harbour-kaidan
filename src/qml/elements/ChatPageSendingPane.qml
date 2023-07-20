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

/**
 * This is a pane for writing and sending chat messages.
 */
DockedPanel {
	id: root

//	background: Kirigami.ShadowedRectangle {
//		shadow.color: Qt.darker(color, 1.2)
//		shadow.size: 4
//		color: Kirigami.Theme.backgroundColor
//	}

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
		}
	}

    Column {
		anchors.fill: parent
		spacing: 0

        Row {
			visible: composition.isSpoiler
			spacing: 0

            TextArea {
				id: spoilerHintField
                width: parent.width
				placeholderText: qsTr("Spoiler hint")
                wrapMode: TextEdit.Wrap
				// background: Item {}
			}

            IconButton {
                //text: qsTr("Close spoiler hint field")
                icon.source: "image://theme/icon-m-close"
                ////FIXME display: Controls.Button.IconOnly
                ////FIXME flat: true

				onClicked: {
					composition.isSpoiler = false
					spoilerHintField.text = ""
				}
			}
		}

        Separator {
			visible: composition.isSpoiler
            width: parent.width
            anchors.topMargin: root.padding
            anchors.bottomMargin: anchors.topMargin
		}

        Row {
			spacing: 0

			// emoji picker button
			ClickableIcon {
                icon.source: "image://theme/icon-m-developer-mode"
				enabled: sendButton.enabled
				onClicked: !emojiPicker.toggle()
			}

			EmojiPicker {
				id: emojiPicker
				x: - root.padding
				y: - height - root.padding
				textArea: messageArea
			}

            TextArea {
				id: messageArea
				placeholderText: MessageModel.isOmemoEncryptionEnabled ? qsTr("Compose <b>encrypted</b> message") : qsTr("Compose <b>unencrypted</b> message")
				// background: Item {}
				wrapMode: TextEdit.Wrap
                anchors.leftMargin: Style.isMaterial ? 6 : 0
                anchors.rightMargin: Style.isMaterial ? 6 : 0
                anchors.bottomMargin: Style.isMaterial ? -8 : 0
                width: parent.width
				verticalAlignment: TextEdit.AlignVCenter
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
//			ClickableIcon {
//                icon.source: MediaUtilsInstance.newMediaIconName(Enums.MessageType.MessageAudio)
//				visible: messageArea.text === ""

//				opacity: visible ? 1 : 0
//				Behavior on opacity {
//					NumberAnimation {}
//				}

//				onClicked: {
//					chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageAudio)
//				}
			}

			// file sharing button
            IconButton {
                icon.source: "image://theme/icon-m-share"
                visible: messageArea.text === ""
				opacity: visible ? 1 : 0
				Behavior on opacity {
					NumberAnimation {}
                }

				property bool checked: false
				onClicked: {
					if (!checked) {
						mediaPopup.open()
						checked = true
					} else {
						mediaPopup.close()
						checked = false
					}
				}
			}

            SilicaControl {
				id: mediaPopup
				x:  root.width - width - 40
				y: - height - root.padding - 20

				width: 470
                Column {
					anchors.fill: parent
//                  AbstractApplicationHeader {
//						width: parent.width
//						leftPadding: Kirigami.Units.largeSpacing
//						SectionHeader {
//							text: qsTr("Attachments")
//						}
//					}
                    SilicaFlickable {
                        anchors.fill: parent

						visible: thumbnails.count !== 0

                        Row {
                            ColumnView {
								id: thumbnails
                                anchors.fill: parent
                                itemHeight: 125
                                model: RecentPicturesModel {}

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
					}

                    Row {
                        Row {
                            anchors.margins: 5

                            IconButton {
                                icon.source: "image://theme/icon-m-camera"
//                                text: qsTr("Take picture")

								onClicked: {
									chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageImage)
									mediaPopup.close()
								}
							}
                            IconButton {
                                icon.source: "image://theme/icon-m-video"
//								title: qsTr("Record video")

								onClicked: {
									chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageVideo)
									mediaPopup.close()
								}
							}
                            IconButton {
                                icon.source: "image://theme/icon-m-document"
//                                title: qsTr("Share files")

								onClicked: {
									chatPage.sendMediaSheet.selectFile()
									mediaPopup.close()
								}
							}
                            IconButton {
                                icon.source: "image://theme/icon-m-location"
//								title: qsTr("Share location")

								onClicked: {
									chatPage.newMediaSheet.sendNewMessageType(MessageModel.currentChatJid, Enums.MessageType.MessageGeoLocation)
									mediaPopup.close()
								}
							}
						}
					}
				}
			}
			ClickableIcon {
				id: sendButton
				visible: messageArea.text !== ""
				opacity: visible ? 1 : 0
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
		}

	/**
	 * Forces the active focus on desktop devices.
	 *
	 * The focus is not forced on mobile devices because the soft keyboard would otherwise pop up.
	 */
//	function forceActiveFocus() {
//
//	}

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
		const currentCharacter = messageArea.getText(messageArea.cursorPosition - 1, messageArea.cursorPosition)

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
					const predecessorOfCurrentCharacter = messageArea.getText(messageArea.cursorPosition - 2, messageArea.cursorPosition - 1)
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
