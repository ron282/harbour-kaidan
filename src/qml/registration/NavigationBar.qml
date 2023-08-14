// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
// import QtQuick.Controls 2.14 as Controls
// import org.kde.kirigami 2.19 as Kirigami

/**
 * This is the navigation bar for the swipe view.
 *
 * It contains buttons for jumping to the previous and the next view.
 * In between the navigation buttons there is an indicator for the current view.
 */
Row {
    width: parent.width
    anchors.margins: 15

	property alias nextButton: nextButton

	// button for jumping to the previous view
    IconButton {
		id: previousButton
        // // Layout.alignment: Qt.AlignLeft
        icon.source: "go-previous-symbolic"
		highlighted: true
		visible: swipeView.currentIndex !== 0
		enabled: jumpingToViewsEnabled
		onClicked: jumpToPreviousView()
	}

	// placeholder for the previous button when it is invisible
	Item {
		width: previousButton.width
		height: previousButton.height
		visible: !previousButton.visible
	}

	// placeholder
	Item {
//		width: parent.width
		width: {
			if (previousButton.visible)
				return previousButton.width
		}
	}

	// indicator for showing the current postion (index) of the siwpe view
/*	Controls.PageIndicator {
		id: indicator
        // Layout.alignment: Qt.AlignCenter

		count: swipeView.count
		currentIndex: swipeView.currentIndex
	}
*/
	// placeholder
	Item {
        width: parent.width
	}

	// placeholder for the next button when it is invisible
	Item {
		width: nextButton.width
		height: nextButton.height
		visible: !nextButton.visible
	}

	// button for jumping to the next view
    IconButton {
		id: nextButton
        // // Layout.alignment: Qt.AlignRight
        icon.source: "go-next-symbolic"
		highlighted: true
		visible: swipeView.currentIndex !== (swipeView.count - 1)
		enabled: jumpingToViewsEnabled
		onClicked: jumpToNextView()
	}
}
