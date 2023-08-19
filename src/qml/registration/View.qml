// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

import "../elements"

/**
 * This is the base for views of the swipe view.
 */
Column {
	property alias descriptionText: description.text
	property alias contentArea: contentArea
	property string imageSource

    SilicaGridView {
		id: contentArea
        anchors.horizontalCenter: parent
        //FIXME Layout.maximumWidth: largeButtonWidth
        anchors.margins: 15
//FIXME		columns: 1
//FIXME		rowSpacing: root.height * 0.05

		Image {
			id: image
			source: imageSource ? Utils.getResourcePath("images/onboarding/" + imageSource + ".svg") : ""
			visible: imageSource
            width: parent.width
            //FIXME Layout.fillHeight: true
			fillMode: Image.PreserveAspectFit
		}

		CenteredAdaptiveText {
			id: description
//			lineHeight: 1.5
		}
	}
}
