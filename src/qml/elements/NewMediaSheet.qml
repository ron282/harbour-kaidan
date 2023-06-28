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
			anchors.topMargin: Kirigami.Units.largeSpacing
			width: parent.width

			Button {
				text: qsTr("Cancel")

				width: parent.width

				onClicked: {
					close()
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
					close()
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
			sourceType = Enums.MessageType.MessageUnknown
		}
	}

	function sendMessageType(jid, type) {
		sourceType = type
		open()
	}

	function sendNewMessageType(jid, type) {
		sendMessageType(jid, type)
	}

	function sendFile(jid, url) {
		source = url
		sendMessageType(jid, MediaUtilsInstance.messageType(url))
	}
}
