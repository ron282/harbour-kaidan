// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Sailfish.Silica 1.0

DetailsSheet {
	id: root

    property string jid

    ContactDetailsHeader {
        id: header
        jid: root.jid
    }

    ContactDetailsContent {
        sheet: root
        jid: root.jid
        width: parent.width
    }
}
