// SPDX-FileCopyrightText: 2018 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0

Dialog {
	property string from;

    Column {
        spacing: Theme.paddingLarge

        DialogHeader {
            title: qsTr("Subscription Request")
        }

        Label {
			text: qsTr("You received a subscription request by <b>%1</b>. " +
				"If you accept it, the account will have access to your " +
				"presence status.").arg(from)
			wrapMode: Text.WordWrap
            width: parent.width
		}

        Row {
			Button {
				text: qsTr("Decline")
				onClicked: {
					Kaidan.client.rosterManager.answerSubscriptionRequestRequested(from, false)
					close()
				}
			}

			Button {
				text: qsTr("Accept")
				onClicked: {
					Kaidan.client.rosterManager.answerSubscriptionRequestRequested(from, true)
					close()
				}
			}
		}
	}
}
