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

//import QtQuick 2.14
import QtQuick 2.2
//import QtQuick.Layouts 1.14
//import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
//import QtMultimedia 5.14 as Multimedia
import QtMultimedia 5.6
//import org.kde.kirigami 2.19 as Kirigami

import MediaUtils 0.1
import im.kaidan.kaidan 1.0

import "elements"
import "details"

ChatPageBase {
	id: root

//	DropArea {
//		anchors.fill: parent
//		onDropped: (drop) => {
//			for (const url of drop.urls) {
//				sendMediaSheet.addFile(url)
//			}
//			sendMediaSheet.ensureOpen()
//		}
//	}

//	Shortcut {
//		sequence: "Ctrl+Shift+V"
//		context: Qt.WindowShortcut
//		onActivated: {
//			let imageUrl = Utils.pasteImage();
//			// check if there was an image to be pasted from the clipboard
//			if (imageUrl.toString().length > 0) {
//				sendMediaSheet.addFile(imageUrl)
//				sendMediaSheet.ensureOpen()
//			}
//		}
//	}

//	property alias searchBar: searchBar
    property alias sendMediaSheet: sendMediaSheet
    property alias newMediaSheet: newMediaSheet
    property alias messageReactionEmojiPicker: messageReactionEmojiPicker
    property alias messageReactionDetailsSheet: messageReactionDetailsSheet

	property ChatPageSendingPane sendingPane
	property ChatInfo globalChatDate
	readonly property bool cameraAvailable: Multimedia.QtMultimedia.availableCameras.length > 0
    property bool viewPositioned: false

    onStatusChanged: {
        if (status === PageStatus.Active && forwardNavigation === false) {
            pageStack.pushAttached(contactDetailsPage)
        }
    }

/*	titleDelegate: Controls.ToolButton {
		visible: !Kirigami.Settings.isMobile

		contentItem: RowLayout {
			// weirdly having an id here, although unused, fixes the layout
			id: layout

			Avatar {
				Layout.leftMargin: Kirigami.Units.largeSpacing
				Layout.preferredHeight: parent.height
				Layout.preferredWidth: parent.height
				jid: MessageModel.currentChatJid
				name: chatItemWatcher.item.displayName
			}
			Kirigami.Heading {
				Layout.fillWidth: true
				Layout.leftMargin: Kirigami.Units.largeSpacing
				Layout.rightMargin: Kirigami.Units.largeSpacing
				text: chatItemWatcher.item.displayName
			}
		}

		onClicked: openOverlay(contactDetailsSheet)
	}
	keyboardNavigationEnabled: true
	contextualActions: [
		Kirigami.Action {
			visible: Kirigami.Settings.isMobile
			icon.name: "avatar-default-symbolic"
			text: qsTr("Details…")
			onTriggered: openPage(contactDetailsPage)
		},
		// Action to toggle the message search bar
		Kirigami.Action {
			id: searchAction
			text: qsTr("Search")
			icon.name: "system-search-symbolic"
			displayHint: Kirigami.DisplayHint.IconOnly
			onTriggered: {
				if (searchBar.active)
					searchBar.close()
				else
					searchBar.open()
			}
		},
		Kirigami.Action {
			visible: !sendingPane.composition.isSpoiler
			icon.name: "password-show-off"
			text: qsTr("Add hidden message part")
			displayHint: Kirigami.DisplayHint.IconOnly
			onTriggered: sendingPane.composition.isSpoiler = true
		}
	]
*/

	// Message search bar
//	header: ChatPageSearchView {
//		id: searchBar
//	}

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height

        PushUpMenu {
            MenuItem {
                visible: false
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
              visible: false
              text: qsTr("Send a spoiler message")
              onClicked: sendingPane.composition.isSpoiler = true
            }
        }

        PageHeader {
            id: header
            title: chatItemWatcher.item.displayName

            Rectangle {
                id: extraContent
                height: Theme.itemSizeMedium
                width: parent.width
                color: "transparent"
                anchors.fill: parent;

                SilicaItem {
                    height: Theme.iconSizeMedium
                    width:Theme.iconSizeMedium
                    anchors {
                        left: parent.left
                        leftMargin: Theme.pageStackIndicatorWidth
                        verticalCenter: parent.verticalCenter
                    }
                    Avatar {
                        id: avatar
                        jid: chatItemWatcher.item.jid
                        name: chatItemWatcher.item.displayName
                        smooth: true;
                        onClicked: contactDetailsSheet.show()
                    }
                }
             }
        }

        ChatPageSearchView {
            anchors.top: header.bottom
            width: parent.width
            id: searchBar
        }

        RosterItemWatcher {
            id: chatItemWatcher
            jid: MessageModel.currentChatJid
        }

        Component {
            id: contactDetailsSheet

            ContactDetailsSheet {
                accountJid: MessageModel.currentAccountJid
                jid: MessageModel.currentChatJid
            }
        }

        Component {
            id: contactDetailsPage

            ContactDetailsPage {
                accountJid: MessageModel.currentAccountJid
                jid: MessageModel.currentChatJid
            }
        }

        Component {
            id: contactDetailsKeyAuthenticationPage

            KeyAuthenticationPage {
    //          Component.onDestruction: openView(contactDetailsSheet, contactDetailsPage)
            }
        }

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

        MessageReactionDetailsSheet {
            id: messageReactionDetailsSheet
        }

    // View containing the messages
//	ListView {
	SilicaListView {
		id: messageListView
        anchors {
            top: searchBar.bottom
            left: parent.left
            right: parent.right
            bottom: sendingPane.top
        }

        verticalLayoutDirection: ListView.BottomToTop
        spacing: 0
        VerticalScrollDecorator { flickable: messageListView }
        cacheBuffer: Screen.width // do avoid flickering when image width is changed
        clip: true;
        //clip: sendMediaSheet.expanded
        focus: true;

		footerPositioning: ListView.OverlayFooter
//		section.property: "nextDate"
//		section.delegate: ColumnLayout {
//			anchors.horizontalCenter: parent.horizontalCenter
//			spacing: 0

//			Item {
//				height: Kirigami.Units.smallSpacing * 3
//			}

//			// placeholder for the hidden chatDate
//			Item {
//				height: chatDate.height
//				visible: !chatDate.visible
//			}

//			ChatInfo {
//				id: chatDate
//				text: section
//				// Hide the date if the section label would display the same date as globalChatDate.
//				visible: root.globalChatDate && text !== root.globalChatDate.text
//			}

//			Item {
//				height: Kirigami.Units.smallSpacing
//			}
//		}


        // Highlighting of the message containing a searched string.

//        highlight: Component {
//			id: highlightBar
//			Rectangle {
//				height: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.implicitHeight
//				width: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.width + Kirigami.Units.smallSpacing * 2
//				color: Kirigami.Theme.hoverColor

//				// This is used to make the highlight bar a little bit bigger than the highlighted message.
//				// It works only together with "messageListView.highlightFollowsCurrentItem: false".
//				y: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.y
//				x: messageListView.currentIndex === -1 ? 0 : messageListView.currentItem.x
//				Behavior on y {
//					SmoothedAnimation {
//						velocity: 1000
//						duration: 500
//					}
//				}

//				Behavior on height {
//					SmoothedAnimation {
//						velocity: 1000
//						duration: 500
//					}
//				}
//			}
//		}
//        // This is used to make the highlight bar a little bit bigger than the highlighted message.
//		highlightFollowsCurrentItem: false

		// Initially highlighted value
		currentIndex: -1

		// Connect to the database,
        model: MessageModel

		Connections {
			target: MessageModel

            onMessageFetchingFinished: {
				// Skip the case when messages are fetched after the initial fetching because this
				// function positioned the view at firstUnreadContactMessageIndex and that is close
				// to the end of the loaded messages.
                if (!root.viewPositioned) {
                   var unreadMessageCount = chatItemWatcher.item.unreadMessageCount

                    if (unreadMessageCount) {
                        var firstUnreadContactMessageIndex = MessageModel.firstUnreadContactMessageIndex()

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

            onMessageSearchFinished: {
				if (queryStringMessageIndex !== -1) {
					messageListView.currentIndex = queryStringMessageIndex
				}

				searchBar.searchFieldBusyIndicator.running = false
			}
		}

		Connections {
			target: Qt.application

            onStateChanged: {
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

        ChatMessageContextMenu {
            id: messageContextMenu
        }

        delegate: ChatMessage {
            contextMenu: messageContextMenu
            reactionEmojiPicker: root.messageReactionEmojiPicker
            reactionDetailsSheet: root.messageReactionDetailsSheet
            modelIndex: index
            msgId: model.id
            senderId: model.senderId
            senderName: model.isOwn ? "" : chatItemWatcher.item.displayName
            chatName: chatItemWatcher.item.displayName
            encryption: model.encryption
            isTrusted: model.isTrusted
            isOwn: model.isOwn
            messageBody: model.body
            date: model.date
            time: model.time
            deliveryState: model.deliveryState
            deliveryStateName: model.deliveryStateName
            deliveryStateIcon: model.deliveryStateIcon
            isLastRead: model.isLastRead
            edited: model.isEdited
            isSpoiler: model.isSpoiler
            spoilerHint: model.spoilerHint
            errorText: model.errorText
            files: model.files
            displayedReactions: model.displayedReactions
            detailedReactions: model.detailedReactions
            ownDetailedReactions: model.ownDetailedReactions
            onMessageEditRequested: {
                sendingPane.prepareMessageCorrection(replaceId, body, spoilerHint)
            }
            onQuoteRequested: {
                var quotedText = ""
                const lines = body.split("\n")

                for (var i = 0; i<lines.length; i++) {
                    quotedText += "> " + lines[i] + "\n"
                }

                sendingPane.messageArea.text = quotedText + sendingPane.messageArea.text
			}
        }

		// Everything is upside down, looks like a footer
/*        header: Column {
            anchors.left: parent.left
            anchors.right: parent.right
            height: stateLabel.text ? 20 : 0

            Label {
                id: stateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: !text ? Theme.paddingMedium : 0
                topPadding: text ? Theme.paddingSmall : 0
                color: Theme.primaryColor

                text: Utils.chatStateDescription(chatItemWatcher.item.displayName, MessageModel.chatState)
                elide: Qt.ElideMiddle
            }
        }*/

/*        footer: BusyIndicator {
            visible: opacity !== 0.0
            anchors.horizontalCenter: parent.horizontalCenter
            height: visible ? undefined : Theme.paddingMedium
            opacity: MessageModel.mamLoading ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 10
                }
            }
		}
*/
/*        IconButton {
            visible: width > 0
            width: parent.atYEnd ? 0 : Theme.buttonWidthLarge
            height: parent.atYEnd ? 0 : Theme.buttonWidthLarge
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            icon.source: "image://theme/icon-s-down"
            onClicked: parent.positionViewAtIndex(0, ListView.Center)

            Behavior on width {
                SmoothedAnimation {}
            }

            Behavior on height {
                SmoothedAnimation {}
            }

            MessageCounter {
                id: unreadMessageCounter
                count: chatItemWatcher.item.unreadMessageCount
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top
                anchors.verticalCenterOffset: -2
            }
        }
*/
    } // SilicaListView

    ChatPageSendingPane {
        id: sendingPane
        chatPage: root
        anchors.bottom: parent.bottom
    }

    function saveDraft() {
        sendingPane.composition.saveDraft();
    }
  }

} // ChatPageBase
