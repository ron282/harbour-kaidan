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
import MediaUtils 0.1
import im.kaidan.kaidan 1.0
import QtMultimedia 5.6

import "elements"
import "details"

ChatPageBase {
	id: root

	property alias searchBar: searchBar
//	property alias sendMediaSheet: sendMediaSheet
//    property alias newMediaSheet: newMediaSheet
//	property alias messageReactionEmojiPicker: messageReactionEmojiPicker
//	property alias messageReactionSenderSheet: messageReactionSenderSheet

	property string messageToCorrect
    readonly property bool cameraAvailable: QtMultimedia.availableCameras.length > 0
	property bool viewPositioned: false

    PageHeader {
        Avatar {
            width: Theme.iconSizeMedium;
            height: width
            jid: chatItemWatcher.item.jid
            name: chatItemWatcher.item.displayName
            smooth: true;
            anchors {
                leftMargin: Theme.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            onClicked: contactDetailsSheet.open()
        }
        Rectangle {
                z: -1;
                color: "black";
                opacity: 0.35;
                anchors.fill: parent;
            }
        ChatPageSearchView {
            id: searchBar
        }
    }

	// Message search bar


    RosterItemWatcher {
		id: chatItemWatcher
		jid: MessageModel.currentChatJid
	}
/*
    ContactDetailsSheet {
		id: contactDetailsSheet
		jid: MessageModel.currentChatJid
	}

    Component {
		id: contactDetailsPage

		ContactDetailsPage {
			jid: MessageModel.currentChatJid
		}
	}
*/
/*
	SendMediaSheet {
		id: sendMediaSheet
		composition: sendingPane.composition
		chatPage: parent
	}

    NewMediaSheet {
        id: newMediaSheet
        composition: sendingPane.composition
    }

	MessageReactionEmojiPicker {
		id: messageReactionEmojiPicker
	}

	MessageReactionSenderSheet {
		id: messageReactionSenderSheet
	}
*/
     // View containing the messages
    SilicaListView {
		id: messageListView
        anchors.fill: parent
        VerticalScrollDecorator { flickable: rosterListView }
        verticalLayoutDirection: ListView.BottomToTop
        cacheBuffer: Screen.width // do avoid flickering when image width is changed
		spacing: 0

        PullDownMenu {
            MenuItem {
                text: qsTr("Details…")
                onClicked: pageStack.push(contactDetailsPage)
            }
            // Action to toggle the message search bar
            MenuItem {
                id: searchAction
                text: qsTr("Search")

                onClicked: {
                    if (searchBar.active)
                        searchBar.close()
                    else
                        searchBar.open()
                }
            }
            MenuItem {
                text: qsTr("Send a spoiler message")
                onClicked: sendingPane.composition.isSpoiler = true
            }
        }

        // Highlighting of the message containing a searched string.
/*
        highlight: Component {
			id: highlightBar
			Rectangle {
				height: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.implicitHeight
				width: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.width + Kirigami.Units.smallSpacing * 2
				color: Kirigami.Theme.hoverColor

				// This is used to make the highlight bar a little bit bigger than the highlighted message.
				// It works only together with "messageListView.highlightFollowsCurrentItem: false".
				y: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.y
				x: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.x
				Behavior on y {
					SmoothedAnimation {
						velocity: 1000
						duration: 500
					}
				}

				Behavior on height {
					SmoothedAnimation {
						velocity: 1000
						duration: 500
					}
				}
			}
		}
        // This is used to make the highlight bar a little bit bigger than the highlighted message.
		highlightFollowsCurrentItem: false
*/
		// Initially highlighted value
		currentIndex: -1

		// Connect to the database,
        model: MessageModel

		Connections {
			target: MessageModel

/*			function onMessageFetchingFinished() {
				// Skip the case when messages are fetched after the initial fetching because this
				// function positioned the view at firstUnreadContactMessageIndex and that is close
				// to the end of the loaded messages.
                if (!root.viewPositioned) {
                   unreadMessageCount = chatItemWatcher.item.unreadMessageCount

                    if (unreadMessageCount) {
                        firstUnreadContactMessageIndex = MessageModel.firstUnreadContactMessageIndex()

                        if (firstUnreadContactMessageIndex > 0) {
                            messageListView.positionViewAtIndex(firstUnreadContactMessageIndex, ListView.End)
                        }

						root.viewPositioned = true

						// Trigger sending read markers manually as the view is ready.
						messageListView.handleMessageRead()
					} else {
						root.viewPositioned = true
					}
				}
			}
*/
			function onMessageSearchFinished(queryStringMessageIndex) {
				if (queryStringMessageIndex !== -1) {
					messageListView.currentIndex = queryStringMessageIndex
				}

				searchBar.searchFieldBusyIndicator.running = false
			}
		}

		Connections {
			target: Qt.application

			function onStateChanged(state) {
				// Send a read marker once the application becomes active if a message has been received while the application was not active.
				if (state === Qt.ApplicationActive) {
					messageListView.handleMessageRead()
				}
			}
		}

		/**
		 * Sends a read marker for the latest visible / read message.
		 */
		function handleMessageRead() {
			if (root.viewPositioned) {
				MessageModel.handleMessageRead(indexAt(0, (contentY + height + 15)) + 1)
			}
		}


		delegate: ChatMessage {
//            contextMenu: ChatMessageContextMenu {
//            }
//			reactionEmojiPicker: root.messageReactionEmojiPicker
//			reactionSenderSheet: root.messageReactionSenderSheet
			modelIndex: index
			msgId: model.id
			senderJid: model.sender
			senderName: model.isOwn ? "" : chatItemWatcher.item.displayName
			chatName: chatItemWatcher.item.displayName
			encryption: model.encryption
			isTrusted: model.isTrusted
			isOwn: model.isOwn
			messageBody: model.body
			dateTime: new Date(model.timestamp)
			deliveryState: model.deliveryState
			deliveryStateName: model.deliveryStateName
			deliveryStateIcon: model.deliveryStateIcon
			isLastRead: model.isLastRead
			edited: model.isEdited
			isSpoiler: model.isSpoiler
			spoilerHint: model.spoilerHint
			errorText: model.errorText
			files: model.files
			reactions: model.reactions

			onMessageEditRequested: {
				messageToCorrect = id

				sendingPane.messageArea.text = body
				sendingPane.messageArea.state = "edit"
			}

			onQuoteRequested: {
//				quotedText = ""
//				const lines = body.split("\n")

//                for (i = 0; i<lines.size(); i++) {
//                    quotedText += "> " + lines[i] + "\n"
//				}

//				sendingPane.messageArea.insert(0, quotedText)
			}
		}

		// Everything is upside down, looks like a footer
        header: Column {
			anchors.left: parent.left
			anchors.right: parent.right
			height: stateLabel.text ? 20 : 0

            Label {
				id: stateLabel
                // Layout.alignment: Qt.AlignCenter
                width: parent.width
				height: !text ? 20 : 0
				topPadding: text ? 10 : 0

				text: Utils.chatStateDescription(chatItemWatcher.item.displayName, MessageModel.chatState)
				elide: Qt.ElideMiddle
			}
		}

        footer: BusyIndicator {
			visible: opacity !== 0.0
			anchors.horizontalCenter: parent.horizontalCenter
            height: visible ? undefined : Theme.paddingMedium
			opacity: MessageModel.mamLoading ? 1.0 : 0.0

//			Behavior on opacity {
//				NumberAnimation {
//					duration: Theme.short
//				}
//			}
		}

        MessageCounter {
				id: unreadMessageCounter
				count: chatItemWatcher.item.unreadMessageCount
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.top
				anchors.verticalCenterOffset: -2
        }


/*        footer: ChatPageSendingPane {
            id: sendingPane
            chatPage: root
        }
*/
        function saveDraft() {
            sendingPane.composition.saveDraft();
        }
    }
}
