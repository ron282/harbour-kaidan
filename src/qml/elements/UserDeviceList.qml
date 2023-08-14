// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

ColumnView {
	property string userJid

	model: UserDevicesModel {
		jid: userJid
	}

	delegate: Column {
		Label {
			text: {
				if (model.name) {
					result = model.name

					if (model.version) {
						result += " v" + model.version
					}

					if (model.os) {
						result += " • " + model.os
					}

					return result
				}

				return model.resource
			}
			textFormat: Text.PlainText
		}
		Item {
			height: 3
		}
	}
}
