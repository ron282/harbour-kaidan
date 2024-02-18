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
import Nemo.Notifications 1.0

import "details"
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

	readonly property color tertiaryBackgroundColor: {
		const accentColor = secondaryBackgroundColor
		return Qt.tint(primaryBackgroundColor, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.7))
	}

	// radius for using rounded corners
    readonly property int roundedCornersRadius: Theme.paddingMedium * 1.5

	readonly property int largeButtonWidth: Theme.buttonWidthLarge
	readonly property int smallButtonWidth: Theme.buttonWidthSmall

	// This is an alias for use in settings ONLY
	// it is only used on mobile, on desktop another item overrides the id "stack"
//    property var stack: SettingsStack {}

//	StatusBar {
//		color: Material.Material.color(Material.Material.Green, Material.Material.Shade700)
//	}

//  globalDrawer: GlobalDrawer {
//        enabled: false
//  }

//	contextDrawer: Kirigami.ContextDrawer {
//		id: contextDrawer
//	}

    // Needed to be outside of the DetailsSheet to not be destroyed with it.
    // Otherwise, the undo action of "showPassiveNotification()" would point to a destroyed object.
    BlockingAction {
        id: blockingAction
        onSucceeded: {
            // Show a passive notification when a JID that is not in the roster is blocked and
            // provide an option to undo that.
            // JIDs in the roster can be blocked again via their details.
            if (!block && !RosterModel.hasItem(jid)) {
//FIXME               showPassiveNotification(qsTr("Unblocked %1").arg(jid), "long", qsTr("Undo"), () => {
//                    blockingAction.block(jid)
//                })
            }
        }
        onErrorOccurred: {
            if (block) {
                showPassiveNotification(qsTr("Could not block %1: %2").arg(jid).arg(errorText))
            } else {
                showPassiveNotification(qsTr("Could not unblock %1: %2").arg(jid).arg(errorText))
            }
        }
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
//  Component {id: accountDetailsSheet; AccountDetailsSheet {}}
//	Component {id: accountDetailsPage; AccountDetailsPage {}}
    Component {id: avatarChangePage; AvatarChangePage {}}
    Component {id: qrCodeOnboardingPage; QrCodeOnboardingPage {}}
    Component {id: contactAdditionPage; ContactAdditionPage {}}
    Component {id: contactAdditionDialog; ContactAdditionDialog {}}
    Component {id: messageNotification; Notification {}}

    Component {
            id: accountDetailsKeyAuthenticationPage

            KeyAuthenticationPage {
                Component.onDestruction: openView(accountDetailsSheet, accountDetailsPage)
            }
    }

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
        showPassiveNotification(text, 4000)
    }

    function showPassiveNotification(text, timeout) {
        var m = messageNotification.createObject(null)
        m.category = "x-nemo.messaging.im"
        m.previewBody = text
        m.expireTimeout = timeout
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
        console.log("[main.qml] openChatView")
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
        console.log("[main.qml] openPage depth="+pageStack.depth)
        popLayersAboveLowest()
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
//        for (i = 0; i < countOfLayersToPop; i++)
//            pageStack.navigateBack(PageStackAction.Immediate)
	}

	/**
	 * Pops all layers except the layer with index 0 from the page stack.
	 */
	function popLayersAboveLowest() {
	}

	/**
	 * Pops all pages from the page stack.
	 */
	function popAllPages() {
        console.log("[main.qml] popAllPages")
        pageStack.clear()
    }

    Connections {

		target: Kaidan

        onRaiseWindowRequested: {
			if (!root.active) {
				root.raise()
				root.requestActivate()
			}
		}

        onPassiveNotificationRequested: {
			passiveNotification(text)
		}

        onCredentialsNeeded: {
			openStartPage()
		}

        onOpenChatViewRequested: {
			openChatView()
		}

        onMessageNotification : {
            var m = messageNotification.createObject(null)
            m.category = "x-nemo.messaging.im"
            m.previewSummary = chatName
            m.previewBody = messageBody
            m.summary = chatName
            m.body = messageBody
            m.clicked.connect(function() {
                Kaidan.openChatPageRequested(AccountManager.jid, chatJid)
                root.activate()
            })
            // This is needed to call default action
            m.remoteActions = [ {
                                   "name": "default",
                                   "displayName": "Show SailKaidan",
                                   "icon": "harbour-kaidan",
                                   "service": "im.kaidan.kaidan",
                                   "path": "/mainWindow",
                                   "iface": "im.kaidan.kaidan",
                                   "method": "showSession",
                                   "arguments": [ "jid", chatJid ]
                               } ]
            m.publish()
        }
    }


    Connections {
		target: RosterModel

        onSubscriptionRequestReceived: {
			Kaidan.client.vCardManager.vCardRequested(from)

			subReqAcceptSheet.from = from

			subReqAcceptSheet.open()
		}
    }

	Component.onCompleted: {
        HostCompletionModel.rosterModel = RosterModel;
        //HostCompletionModel.aggregateKnownProviders();

		if (AccountManager.loadConnectionData()) {
			openChatView()
            // Announce that the user interface is ready and the application can start connecting.
            Kaidan.logIn()
		} else {
			openStartPage()
		}
    }

    cover: CoverBackground {

        property int unreadMessages : 0

        Image {
            id: bgimg
            source: Utils.getResourcePath("images/sailkaidan-cover.png")
            anchors.fill: parent
        }
        Column {
            anchors.top: parent.top
            width: parent.width
            spacing: Theme.paddingMedium

            Label {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                text:  Utils.applicationDisplayName
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Kaidan.connectionStateText
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeHuge
                text: cover.unreadMessages.toString();
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                maximumLineCount: 2
                wrapMode: Text.Wrap
                fontSizeMode: Text.HorizontalFit
                text: qsTr("Unread messages")
            }
        }

        Connections {
            target: Kaidan
            onMessageNotification: {
                if (!root.active) {
                    cover.unreadMessages++
                }
            }
        }

        Connections
        {
            target: root.pageStack.currentPage
            onStatusChanged: if(root.pageStack.currentPage.status === PageStatus.Active)
                cover.resetUnreadMessages()
        }

        function resetUnreadMessages() {
            cover.unreadMessages = 0
        }
    }
}
