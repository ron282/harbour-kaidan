/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.14
import QtQuick.Controls.Material 2.14 as Material
import org.kde.kirigami 2.19 as Kirigami
import StatusBar 0.1

import im.kaidan.kaidan 1.0

import "elements"
import "registration"
import "settings"

Kirigami.ApplicationWindow {
	id: root

	minimumHeight: 300
	minimumWidth: 280

	readonly property ChatPage currentChatPage: {
		for (var i = 0; i < pageStack.items.length; ++i) {
			var page = pageStack.items[i];

			if (page instanceof ChatPage) {
				return page;
			}
		}

		return null;
	}

	property bool currentDraftSaved: false

	readonly property color primaryBackgroundColor: {
		Kirigami.Theme.colorSet = Kirigami.Theme.View
		return Kirigami.Theme.backgroundColor
	}

	readonly property color secondaryBackgroundColor: {
		Kirigami.Theme.colorSet = Kirigami.Theme.Window
		return Kirigami.Theme.backgroundColor
	}

	// radius for using rounded corners
	readonly property int roundedCornersRadius: Kirigami.Units.smallSpacing * 1.5

	readonly property int largeButtonWidth: Kirigami.Units.gridUnit * 25
	readonly property int smallButtonWidth: Kirigami.Theme.defaultFont.pixelSize * 2.9

	// This is an alias for use in settings ONLY
	// it is only used on mobile, on desktop another item overrides the id "stack"
	property var stack: SettingsStack {}

	StatusBar {
		color: Material.Material.color(Material.Material.Green, Material.Material.Shade700)
	}

	// Global and Contextual Drawers
	// It is initialized as invisible.
	// That way, it does not pop up for a moment before the startPage is opened.
	globalDrawer: GlobalDrawer {
		enabled: false
	}

	contextDrawer: Kirigami.ContextDrawer {
		id: contextDrawer
	}


	SubRequestAcceptSheet {
		id: subReqAcceptSheet
	}

	// components for all main pages
	Component {id: startPage; StartPage {}}
	Component {id: registrationLoginDecisionPage; RegistrationLoginDecisionPage {}}
	Component {id: registrationDecisionPage; RegistrationDecisionPage {}}
	Component {id: automaticRegistrationPage; AutomaticRegistrationPage {}}
	Component {id: manualRegistrationPage; ManualRegistrationPage {}}
	Component {id: loginPage; LoginPage {}}
	Component {id: rosterPage; RosterPage {}}
	Component {id: chatPage; ChatPage {}}
	Component {id: emptyChatPage; EmptyChatPage {}}
	Component {id: settingsPage; SettingsPage {}}
	Component {id: qrCodeOnboardingPage; QrCodeOnboardingPage {}}

	onWideScreenChanged: showRosterPageForNarrowWindow()

	onClosing: {
		if (currentChatPage) {
			if (!currentDraftSaved) {
				currentChatPage.saveDraft();

				close.accepted = false;

				Qt.callLater(function() {
					root.currentDraftSaved = true;
					root.close();
				});
			}
		}
	}

	/**
	 * Shows a passive notification for a long period.
	 */
	function passiveNotification(text) {
		showPassiveNotification(text, "long")
	}

	function openStartPage() {
		globalDrawer.enabled = false

		popLayersAboveLowest()
		popAllPages()
		pageStack.push(startPage)
	}

	/**
	 * Opens the view with the roster and chat page.
	 */
	function openChatView() {
		globalDrawer.enabled = true

		popLayersAboveLowest()
		popAllPages()
		pageStack.push(rosterPage)
		if (!Kirigami.Settings.isMobile)
			pageStack.push(emptyChatPage)
		showRosterPageForNarrowWindow()
	}

	// Show the rosterPage instead of the emptyChatPage if the window is narrow.
	function showRosterPageForNarrowWindow() {
		if (pageStack.layers.depth < 2 && pageStack.currentItem instanceof EmptyChatPage && !wideScreen)
			pageStack.goBack()
	}

	/**
	 * Pops a given count of layers from the page stack.
	 *
	 * @param countOfLayersToPop count of layers which are popped
	 */
	function popLayers(countOfLayersToPop) {
		for (let i = 0; i < countOfLayersToPop; i++)
			pageStack.layers.pop()
	}

	/**
	 * Pops all layers except the layer with index 0 from the page stack.
	 */
	function popLayersAboveLowest() {
		while (pageStack.layers.depth > 1)
			pageStack.layers.pop()
	}

	/**
	 * Pops all pages from the page stack.
	 */
	function popAllPages() {
		while (pageStack.depth > 0)
			pageStack.pop()
	}

	Connections {
		target: Kaidan

		function onRaiseWindowRequested() {
			if (!root.active) {
				root.raise()
				root.requestActivate()
			}
		}

		function onPassiveNotificationRequested(text) {
			passiveNotification(text)
		}

		function onCredentialsNeeded() {
			openStartPage()
		}

		function onOpenChatViewRequested() {
			openChatView()
		}
	}

	Connections {
		target: RosterModel

		function onSubscriptionRequestReceived(from, msg) {
			Kaidan.client.vCardManager.vCardRequested(from)

			subReqAcceptSheet.from = from

			subReqAcceptSheet.open()
		}
	}

	Component.onCompleted: {
		// Restore the latest application window state if it is stored.
		if (!Kirigami.Settings.isMobile) {
			const latestPosition = Kaidan.settings.windowPosition
			root.x = latestPosition.x
			root.y = latestPosition.y

			const latestSize = Kaidan.settings.windowSize
			if (latestSize.width > 0) {
				root.width = latestSize.width
				root.height = latestSize.height
			}
		}

		if (AccountManager.loadConnectionData()) {
			openChatView()
			// Announce that the user interface is ready and the application can start connecting.
			Kaidan.logIn()
		} else {
			openStartPage()
		}
	}

	Component.onDestruction: {
		// Store the application window state for restoring the latest state on the next start.
		if (!Kirigami.Settings.isMobile) {
			Kaidan.settings.windowPosition = Qt.point(x, y)
			Kaidan.settings.windowSize = Qt.size(width, height)
		}
	}
}
