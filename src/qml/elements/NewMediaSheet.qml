// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2022 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import QtQuick.Controls 2.14 as Controls
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

DockedPanel {
	id: root

	property int sourceType
	property string source
	property MessageComposition composition

	signal rejected()
	signal accepted()

//	showCloseButton: false

	 Column {
		// message type preview
		Loader {
			id: loader

			enabled: true
			visible: enabled
			sourceComponent: newMediaComponent

			//FIXME Layout.fillHeight: item ? item.Layout.fillHeight : false
            width : item ? item.width : nul
            //Layout.fillWidth: item ? item.Layout.fillWidth : false
			// //FIXME Layout.preferredHeight: item ? item.// Layout.preferredHeight : -1
			//FIXME Layout.preferredWidth: item ? item.Layout.preferredWidth : -1
			//FIXME Layout.minimumHeight: item ? item.Layout.minimumHeight : -1
            // Layout.minimumWidth: item ? item.Layout.minimumWidth : -1
            // Layout.maximumHeight: item ? item.Layout.maximumHeight : -1
			//FIXME Layout.maximumWidth: item ? item.Layout.maximumWidth : -1
			// Layout.alignment: item ? item.Layout.alignment : Qt.AlignCenter
			anchors.margins: item ? item.anchors.margins : 0
			anchors.leftMargin: item ? item.anchors.leftMargin : 0
			anchors.topMargin: item ? item.anchors.topMargin : 0
			anchors.rightMargin: item ? item.anchors.rightMargin : 0
			anchors.bottomMargin: item ? item.anchors.bottomMargin : 0

			Component {
				id: newMediaComponent

				NewMediaLoader {
					mediaSourceType: root.sourceType
					mediaSheet: root
				}
			}

			Component {
				id: mediaPreviewComponent

				MediaPreviewLoader {
					mediaSource: root.source
					mediaSourceType: root.sourceType
					mediaSheet: root
				}
			}
		}

		// buttons for send/cancel
		Row {
            anchors.topMargin: Theme.paddingLarge
			width: parent.width

			Button {
				text: qsTr("Cancel")

				width: parent.width

				onClicked: {
                    hide()
					root.rejected()
				}
			}

			Button {
				id: sendButton

				enabled: root.source
				text: qsTr("Send")

				width: parent.width

				onClicked: {
					composition.fileSelectionModel.addFile(root.source)
					composition.send()
                    hide()
					root.accepted()
				}
			}
		}

		Keys.onPressed: {
			if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
				sendButton.clicked()
			}
		}
	}

    onOpenChanged: {
        if (!open) {
            sourceType = Enums.MessageUnknown
		}
	}

	function sendMessageType(jid, type) {
		sourceType = type
        show()
	}

	function sendNewMessageType(jid, type) {
		sendMessageType(jid, type)
	}

	function sendFile(jid, url) {
		source = url
		sendMessageType(jid, MediaUtilsInstance.messageType(url))
	}
}
