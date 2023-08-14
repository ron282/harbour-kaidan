// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is the base for a chat page.
 */
Page {
        // color of the message bubbles on the right side
        readonly property color rightMessageBubbleColor: {
            const accentColor = Theme.highlightColor
            return Theme.highlightColor
//            return Qt.tint(Theme.backgroundColor, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1))
        }
}
