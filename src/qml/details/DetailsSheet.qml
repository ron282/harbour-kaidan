// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

DockedPanel {
	id: root

	default property alias __data: mainArea.data

//	topPadding: 0
//	bottomPadding: 0
//	leftPadding: 0
//	rightPadding: 0
    //FIXME Kirigami.Theme.colorSet: Kirigami.Theme.Header

    dock: Dock.Bottom
    width: parent.width
    height: mainArea.height


	Column {
		id: mainArea
        anchors.centerIn: parent
		//FIXME Layout.preferredWidth: 600
        //FIXME Layout.preferredHeight: 600
        //FIXME Layout.maximumWidth: 600
	}
}
