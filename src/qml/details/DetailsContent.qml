// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import ".."
import "../elements"

Column {
	id: root

//  default property alias __data: mainArea.data
    property Page sheet
    property string jid
	property alias qrCodePage: qrCodePage
    property alias automaticMediaDownloadsDelegate: automaticMediaDownloadsDelegate
    property alias mediaOverview: mediaOverview
    property alias mediaOverviewExpansionButton: mediaOverviewExpansionButton
    property alias vCardArea: vCardArea.data
    property alias vCardRepeater: vCardRepeater
	property alias rosterGoupListView: rosterGoupListView
	property Column encryptionArea
	property alias extraContentArea: extraContent.data

    width: parent.width

    Column {
        id: mainArea
        width: parent.width
        spacing: Theme.paddingLarge

        Component {
            id: qrCodePage

            QrCodePage {
                Component.onCompleted: {
                    if (root.sheet) {
                        root.sheet.close()
                    }
                }

                Component.onDestruction: {
                    if (root.sheet) {
                        root.sheet.open()
                    }
                }
            }
        }

        Column {
            width: parent.width

            SectionHeader {
                text: qsTr("Media")
            }

            ComboBox {
                id: automaticMediaDownloadsDelegate
                label: qsTr("Automatic Downloads")
                description: qsTr("Download media automatically")

                // "FormComboBoxDelegate.indexOfValue()" seems to not work with an array-based
                // model.
                // Thus, an own function is used.
                function indexOf(value) {
                    var parent = menu
                    for (var i=0; i < menu.children.length; i++) {
                        var child = menu.children[i]
                        if( child.value === value)
                            return i;
                    }
                    return -1
                }
            }

            MediaOverview {
                id: mediaOverview
				visible: mediaOverviewExpansionButton.visible && mediaOverviewExpansionButton.checked
				width: parent.width - 2*Theme.horizontalPageMargin
            }

			FormExpansionButton {
				id: mediaOverviewExpansionButton
				anchors.right: parent.right
				onCheckedChanged: {
					if (checked) {
						mediaOverview.selectionMode = false

						// Display the content of the first tab only on initial loading.
						// Afterwards, display the content of the last active tab.
						if (mediaOverview.tabBarCurrentIndex === -1) {
							mediaOverview.tabBarCurrentIndex = 0
						}

						mediaOverview.loadDownloadedFiles()
					}
				}
			}
		}

        Column {
            id: vCardArea
			visible: vCardRepeater.count || vCardRepeater.model.jid === AccountManager.jid
            width: parent.width

            SectionHeader {
                 text: qsTr("Profile")
            }

            ColumnView {
                id: vCardRepeater
                itemHeight: Theme.itemSizeMedium + Theme.paddingSmall
            }
        }

		Column {
			children : [ root.encryptionArea ]
            width: parent.width
        }

		Column {
            // Hide this if there are no items and no header.
			visible: rosterGoupListView.count || rosterGoupListView.headerItem
            width: parent.width

            spacing: 0

            SectionHeader {
                text: qsTr("Labels")
            }

			ListView {
				id: rosterGoupListView
				visible: rosterGoupExpansionButton.checked
				model: RosterModel.groups
				width: parent.width
				height: Theme.itemSizeSmall*count
			}

			FormExpansionButton {
				anchors.right: parent.right
				id: rosterGoupExpansionButton
			}
		}

        Column {
            width: parent.width
            visible: deviceRepeater.count

            SectionHeader {
                text: qsTr("Connected Devices")
            }

            ColumnView {
                id: deviceRepeater
				visible: deviceExpansionButton.checked
				itemHeight: Theme.itemSizeMedium
                model: UserDevicesModel {
                    jid: root.jid
                }
                delegate: BackgroundItem {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    Row {
                        width: parent.width
                        spacing: Theme.paddingMedium
                        Icon {
                            id: deviceIcon
                            source: "image://theme/icon-m-tether"
                            sourceSize: Qt.size(Theme.iconSizeMedium, Theme.iconSizeMedium)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            width: parent.width - deviceIcon.width - Theme.paddingMedium
                            Label {
                                text: {
                                    if (model.name) {
                                        if (model.version) {
                                            return model.name + " " + model.version
                                        }
                                        return model.name
                                    }
                                    return model.resource
                                }
                                textFormat: Text.PlainText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                            Label {
                                text: model.os
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                textFormat: Text.PlainText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }			
			FormExpansionButton {
				anchors.right: parent.right
				id: deviceExpansionButton
			}
		}
        Column {
            id: extraContent
            width: parent.width
        }
    }

    function openKeyAuthenticationPage(keyAuthenticationPageComponent, accountJid, chatJid) {
        if (root.sheet) {
            root.sheet.close()
        }

        var keyAuthenticationPage = openPage(keyAuthenticationPageComponent)
        keyAuthenticationPage.accountJid = accountJid
        keyAuthenticationPage.chatJid = chatJid
    }
}
