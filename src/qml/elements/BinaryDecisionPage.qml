// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
//import QtQuick 2.2
//import Sailfish.Silica 1.0
//// import org.kde.kirigami 2.19 as Kirigami

/**
 * This page is the base of decision pages with two actions.
 *
 * Each action has an own image for describing its purpose.
 */
Page {
	property alias top//FIXME description: topDescription.text
	property alias bottom//FIXME description: bottomDescription.text

	property alias topImageSource: topImage.source
	property alias bottomImageSource: bottomImage.source

    property Action topAction
    property Action bottomAction

    property bool topActionAsMainAction: false

	property int descriptionMargin: 10

    PullDownMenu {
        MenuItem {
            visible: topAction != null 
            text: topDescription
            onClicked: topAction.trigger()
        }
    }
  
    PushUpMenu {
        MenuItem {
            visible: bottomAction != null 
            text: bottomDescription
            onClicked: bottomAction
        }
    }

    Column {
		anchors.fill: parent

		Column {
			width: largeButtonWidth
			anchors.horizontalCenter: parent.horizontalCenter

			// image to show above the top action
			Icon {
				id: topImage
			}

			// description for the top action
			CenteredAdaptiveText {
				id: topDescription
			}

			// button for the top action
			CenteredAdaptiveButton {
				visible: !topActionAsMainAction
				text: topAction.text
				icon.source: topAction.icon.name
				onClicked: topAction.trigger()
				enabled: topAction.enabled
			}

			// button for the top action as main action
			CenteredAdaptiveHighlightedButton {
				visible: topActionAsMainAction
				text: topAction.text
				icon.source: topAction.icon.name
				onClicked: topAction.trigger()
				enabled: topAction.enabled
			}

			// horizontal line to separate the two actions
            Separator {
			}

			// button for the bottom action
			CenteredAdaptiveButton {
				text: bottomAction.text
				icon.source: bottomAction.icon.name
				onClicked: bottomAction.trigger()
				enabled: bottomAction.enabled
			}

			// description for the bottom action
			CenteredAdaptiveText {
				id: bottomDescription
			}

			// image to show below the bottom action
            Icon {
				id: bottomImage
			}
		}
	}
}
