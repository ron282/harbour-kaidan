// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

Flow {
	property alias primaryExplanationText: primaryExplanationText
	property alias primaryExplanationImage: primaryExplanationImage
	property alias secondaryExplanationText: secondaryExplanationText
	property alias secondaryExplanationImage: secondaryExplanationImage

    flow: parent.width > parent.height ? Flow.LeftToRight : Flow.TopToBottom
    property int rowSpacing: Theme.paddingLarge * 2
    property int columnSpacing: rowSpacing
	width: parent.width
	height: parent.height

    Flow  {
        width: parent.flow === Flow.TopToBottom ? parent.width : parent.width / 2 - parent.columnSpacing * 2
        height: parent.flow === Flow.LeftToRight ? parent.height : parent.height / 2 - parent.rowSpacing * 2

		CenteredAdaptiveText {
			id: primaryExplanationText
            scaleFactor: 1 // 1.5
		}

		Image {
			id: primaryExplanationImage
			sourceSize: Qt.size(860, 860)
			fillMode: Image.PreserveAspectFit
//			mipmap: true
            width: parent.width
		}
	}

    Separator {
        width: parent.flow === Flow.TopToBottom ? parent.width : undefined
        height: parent.flow === Flow.LeftToRight ? parent.height : undefined
//		Layout.topMargin: parent.flow === GridLayout.LeftToRight ? parent.height * 0.1 : 0
//		Layout.bottomMargin: Layout.topMargin
//		Layout.leftMargin: parent.flow === GridLayout.TopToBottom ? parent.width * 0.1 : 0
//		Layout.rightMargin: Layout.leftMargin
//		Layout.alignment: Qt.AlignCenter
    }

    Flow {
        width: parent.flow === Flow.TopToBottom ? parent.width : parent.width / 2 - parent.columnSpacing * 2
        height: parent.flow === Flow.LeftToRight ? parent.height : parent.height / 2 - parent.rowSpacing * 2

		CenteredAdaptiveText {
			id: secondaryExplanationText
            scaleFactor: 1 // 1.5
		}

		Image {
			id: secondaryExplanationImage
			sourceSize: Qt.size(860, 860)
			fillMode: Image.PreserveAspectFit
//			mipmap: true
            width: parent.width
		}
	}
}
