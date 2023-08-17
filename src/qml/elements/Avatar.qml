// SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import im.kaidan.kaidan 1.0


Image {
    id: root
    signal clicked
    property string jid
    property string name
    width: parent.height
    height: width

    source: Kaidan.avatarStorage.getAvatarUrl(jid)
    fillMode: Image.PreserveAspectCrop;
    antialiasing: true;

    Icon {
        source: "image://theme/icon-m-contact"
        visible: root.status != Image.Ready
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
