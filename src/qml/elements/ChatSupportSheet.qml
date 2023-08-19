// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

Page {
	id: root

	property var chatSupportList
	property bool isGroupChatSupportSheet: false

    PageHeader {
        title: isGroupChatSupportSheet ? qsTr("Support Group") : qsTr("Support")
		wrapMode: Text.WordWrap
	}

    SilicaListView {
		implicitWidth: largeButtonWidth
		clip: true
        model: chatSupportList

		RosterAddContactSheet {
			id: addContactSheet
		}

        delegate: ListItem {
			property int index
			property string modelData
			readonly property string chatName: {
				(isGroupChatSupportSheet ? qsTr("Group Support %1") : qsTr("Support %1")).arg(index + 1)
			}

			height: 65

            Column {
				spacing: 12

                Label {
					text: chatName
					font.bold: true
				}

                Label {
					text: modelData
					wrapMode: Text.Wrap
				}
			}

			onClicked: {
				if (isGroupChatSupportSheet) {
					Qt.openUrlExternally("xmpp:" + modelData + "?join")
				} else {
                    var contactAdditionContainer = openView(contactAdditionDialog, contactAdditionPage)
					contactAdditionContainer.jid = modelData
					contactAdditionContainer.name = chatName
				}

				root.close()
			}
		}
	}
}
