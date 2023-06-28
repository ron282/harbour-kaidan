/*
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

Button {
	id: root

    property alias buttonIcon: icon.source
    property alias title: text
	property string subtitle
	property string tooltipText
}
