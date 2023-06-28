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
// import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

import "fields"

Dialog {
	property string jid: ""
	property string nickname: ""
	parent: applicationWindow().overlay
    DialogHeader
    {
        title: qsTr("Add new contact")
    }
	onRejected: {
		clearInput()
		close()
	}
    onDone: {
        if (result == DialogResult.Accepted) {
				Kaidan.client.rosterManager.addContactRequested(
						jidField.text.toLowerCase(),
						nickField.text,
						msgField.text
				)
				clearInput()
				close()

				Kaidan.openChatPageRequested(AccountManager.jid, jidField.text)
			}
    }

	CredentialsValidator {
		id: credentialsValidator
	}

	Column {
		width: parent.width
        spacing: Theme.paddingMedium
        Label {
			visible: true
			//FIXME Layout.preferredWidth: 400
			width: parent.width
            // type: Kirigami.MessageType.Information

			text:  qsTr("This will also send a request to access the " +
						"presence of the contact.")
		}

		Label {
			text: qsTr("Jabber-ID:")
		}
		JidField {
			id: jidField
			text: jid
			width: parent.width
		}

		Label {
			text: qsTr("Nickname:")
		}
		TextField {
			id: nickField
            // selectByMouse: true
			width: parent.width
			text: nickname
		}

		Label {
			text: qsTr("Optional message:")
			textFormat: Text.PlainText
			width: parent.width
		}
        TextArea {
			id: msgField
			width: parent.width
            //FIXME Layout.minimumHeight: Kirigami.Units.gridUnit * 4
			placeholderText: qsTr("Tell your chat partner who you are.")
            wrapMode: TextArea.Wrap
            // selectByMouse: true
		}
	}

	function clearInput() {
		jid = "";
		nickname = "";
		msgField.text = "";
	}
}
