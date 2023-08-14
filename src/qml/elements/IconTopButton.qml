// SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2022 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

Button {
	id: root

    property alias buttonIcon: icon.source
    property alias title: text
	property string subtitle
	property string tooltipText
}
