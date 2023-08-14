// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0

DetailsPage {
	id: root

    property string jid

	ContactDetailsHeader {
		jid: root.jid
	}

/*	ContactDetailsContent {
		jid: root.jid
		width: parent.width
	}
*/
}
