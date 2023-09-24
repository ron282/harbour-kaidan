// SPDX-FileCopyrightText: 2016 geobra <s.g.b@gmx.de>
// SPDX-FileCopyrightText: 2016 Marzanna <MRZA-MRZA@users.noreply.github.com>
// SPDX-FileCopyrightText: 2016 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2016 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2017 Ilya Bizyaev <bizyaev@zoho.com>
// SPDX-FileCopyrightText: 2018 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Bhavy Airi <airiraghav@gmail.com>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
//import StatusBar 0.1
import im.kaidan.kaidan 1.0
import org.nemomobile.notifications 1.0


import "elements"
import "registration"
import "settings"


ApplicationWindow {
	id: root

    property bool wideScreen: false
    readonly property ChatPage currentChatPage: {
        return pageStack.find(function(p) {
            return p instanceof ChatPage
        });
    }

	property bool currentDraftSaved: false

	readonly property color primaryBackgroundColor: {
		return Theme.primaryColor
	}

	readonly property color secondaryBackgroundColor: {
		return Theme.lightPrimaryColor
	}

	// radius for using rounded corners
    readonly property int roundedCornersRadius: Theme.itemSizeExtraSmall * 1.1

	readonly property int largeButtonWidth: Theme.buttonWidthLarge
	readonly property int smallButtonWidth: Theme.buttonWidthSmall

	// This is an alias for use in settings ONLY
	// it is only used on mobile, on desktop another item overrides the id "stack"
//    property var stack: SettingsStack {}

//	StatusBar {
//		color: Material.Material.color(Material.Material.Green, Material.Material.Shade700)
//	}

	// Global and Contextual Drawers
	// It is initialized as invisible.
	// That way, it does not pop up for a moment before the startPage is opened.
    property Item _dockedPanel

    bottomMargin: _dockedPanel ? _dockedPanel.visibleSize : 0

//  globalDrawer: GlobalDrawer {
//        enabled: false
//  }

    function dockedPanel() {
        if (!_dockedPanel) _dockedPanel = globalDrawer.createObject(contentItem)
        return _dockedPanel
    }

//	contextDrawer: Kirigami.ContextDrawer {
//		id: contextDrawer
//	}


    SubRequestAcceptSheet {
        id: subReqAcceptSheet
    }

    // components for all main pages
	Component {id: startPage; StartPage {}}
    Component {id: globalDrawer; GlobalDrawer {}}
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
    Component {id: contactAdditionPage; ContactAdditionPage {}}
    Component {id: contactAdditionDialog; ContactAdditionDialog {}}
    Component {id: messageNotification; Notification {}}

//	onWideScreenChanged: showRosterPageForNarrowWindow()

//	onClosing: {
//		if (currentChatPage) {
//			if (!currentDraftSaved) {
//				currentChatPage.saveDraft();
//
//				close.accepted = false;
//
//				Qt.callLater(function() {
//					root.currentDraftSaved = true;
//					root.close();
//				});
//			}
//		}
//	}
	/**
	 * Shows a passive notification for a long period.
	 */
    function passiveNotification(text) {
        showPassiveNotification(text, "long")
    }

    function showPassiveNotification(text, style) {
        var m = messageNotification.createObject(null)
        m.category = "x-nemo.messaging.im"
        m.previewBody = text
        // This is needed to call default action
        m.publish()
    }

	function openStartPage() {
//        globalDrawer.open = false
//        dockedPanel().hide()
        popLayersAboveLowest()
        popAllPages()
        pageStack.push(startPage)
	}

	/**
	 * Opens the view with the roster and chat page.
	 */
	function openChatView() {
        console.log("[main.qml] OpenChatView called")

//        globalDrawer.open = true
//        dockedPanel().show()

        popLayersAboveLowest()
        popAllPages()

        pageStack.push(globalDrawer, {}, PageStackAction.Immediate)
        pageStack.pushAttached(rosterPage, {}, PageStackAction.Immediate)
        pageStack.navigateForward(PageStackAction.Immediate)
        showRosterPageForNarrowWindow()
	}

	/**
	 * Creates and opens an overlay (e.g., Kirigami.OverlaySheet or Kirigami.Dialog) on desktop
	 * devices or a page (e.g., Kirigami.ScrollablePage) on mobile devices.
	 *
	 * @param overlayComponent component containing the overlay to be opened
	 * @param pageComponent component containing the page to be opened
	 *
	 * @return the opened page or sheet
	 */
	function openView(overlayComponent, pageComponent) {
        if (true) {
			return openPage(pageComponent)
		} else {
			return openOverlay(overlayComponent)
		}
	}

	function openOverlay(overlayComponent) {
        var overlay = overlayComponent.createObject(root)
		overlay.open()
		return overlay
	}

	function openPage(pageComponent) {
        //popLayersAboveLowest()
        return pageStack.push(pageComponent)
	}

	// Show the rosterPage instead of the emptyChatPage if the window is narrow.
	function showRosterPageForNarrowWindow() {
//        if (pageStack.depth < 2 && pageStack.currentItem instanceof EmptyChatPage && !wideScreen)
//            pageStack.navigateBack(PageStackAction.Immediate)
	}

	/**
	 * Pops a given count of layers from the page stack.
	 *
	 * @param countOfLayersToPop count of layers which are popped
	 */
	function popLayers(countOfLayersToPop) {
        for (i = 0; i < countOfLayersToPop; i++)
            pageStack.navigateBack(PageStackAction.Immediate)
	}

	/**
	 * Pops all layers except the layer with index 0 from the page stack.
	 */
	function popLayersAboveLowest() {
        while (pageStack.depth > 2)
            pageStack.navigateBack(PageStackAction.Immediate)
	}

	/**
	 * Pops all pages from the page stack.
	 */
	function popAllPages() {
        pageStack.clear()
    }

    Connections {

		target: Kaidan

        onRaiseWindowRequested: {
            console.log("[main.qml] onRaiseWindowRequested")
			if (!root.active) {
				root.raise()
				root.requestActivate()
			}
		}

        onPassiveNotificationRequested: {
            console.log("[main.qml] onPassiveNotificationRequested")
			passiveNotification(text)
		}

        onCredentialsNeeded: {
            console.log("[main.qml] onCredentialsNeeded")
			openStartPage()
		}

        onOpenChatViewRequested: {
            console.log("[main.qml] onOpenChatViewRequested")
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
        console.log("[main.qml] onComponentCompleted")
        HostCompletionModel.rosterModel = RosterModel;
        //HostCompletionModel.aggregateKnownProviders();

		if (AccountManager.loadConnectionData()) {
			openChatView()
            console.log("[main.qml] Kaidan.logIn()")
            // Announce that the user interface is ready and the application can start connecting.
            Kaidan.logIn()
		} else {
			openStartPage()
		}
    }

    cover: CoverBackground {
        Image {
            id: bgimg
            source: Utils.getResourcePath("images/kaidan-cover.png")
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: sourceSize.height * width / sourceSize.width
        }
        Column {
            id: cover
            anchors.top: parent.top
            width: parent.width
            spacing: Theme.paddingMedium

            Label {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamilyHeading
                color: Theme.primaryColor
                text:  Utils.applicationDisplayName
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFamily
                text: Kaidan.connectionStateText
            }
        }
    }
}
