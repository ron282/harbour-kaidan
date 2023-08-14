// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0


BackgroundItem {
    id: root
    property string jid
    property string name
    width: parent.height
    height: width

    Image {
        id: img
        source: Kaidan.avatarStorage.getAvatarUrl(jid)
        visible: source != ""
        fillMode: Image.PreserveAspectCrop;
        antialiasing: true;
        anchors.fill: parent
    }
    Icon {
        source: "image://theme/icon-m-contact"
        visible: !img.visible
        anchors.fill: parent
    }
}
