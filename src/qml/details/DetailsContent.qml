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
    property alias rosterGroupArea: rosterGroupZone.data
    property alias encryptionArea: encryptionZone.data
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
                        if( child.value == value)
                            return i;
                    }
                    return -1
                }
            }

            FormExpansionButton {
                id: mediaOverviewExpansionButton
                visible: false
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

            MediaOverview {
                id: mediaOverview
                visible: false // mediaOverviewExpansionButton.checked
                width: parent.width
            }
        }

        Column {
            id: vCardArea
            visible: vCardRepeater.count
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
            id: rosterGroupZone
            width: parent.width
        }

        Column {
            id: encryptionZone
            width: parent.width
        }

        /*Column {
            // Hide this if there are no items and no header.
            visible: rosterGoupListView.count || rosterGoupListView.headerItem
            width: parent.width

            spacing: 0

            SectionHeader {
                text: qsTr("Labels")
            }

            ListView {
                id: rosterGoupListView
                model: RosterModel.groups
                visible: rosterGroupExpansionButton.checked
                implicitHeight: contentHeight
            }
        }*/

        Column {
            width: parent.width
            visible: deviceRepeater.count

            SectionHeader {
                text: qsTr("Connected Devices")
            }

            ColumnView {
                id: deviceRepeater
                itemHeight: Theme.itemSizeSmall
                model: UserDevicesModel {
                    jid: root.jid
                }
                delegate: Row {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2*Theme.horizontalPageMargin - Theme.paddingMedium
                    spacing: Theme.paddingMedium
                    Icon {
                        id: deviceIcon
                        source: {
                            if (model.os.indexOf("Android") < 0 && model.os.indexOf("Sailfish") < 0 )
                                return "image://theme/icon-l-computer"
                            else
                                return "image://theme/icon-m-device"
                        }
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
        Column {
            id: extraContent
            width: parent.width
        }
    }
//=======
//	default property alias __data: mainArea.data
//	property Kirigami.OverlaySheet sheet
//	required property string jid
//	property alias automaticMediaDownloadsDelegate: automaticMediaDownloadsDelegate
//	property alias mediaOverview: mediaOverview
//	property alias mediaOverviewExpansionButton: mediaOverviewExpansionButton
//	property alias vCardArea: vCardArea.data
//	property alias vCardRepeater: vCardRepeater
//	property alias rosterGoupListView: rosterGoupListView
//	required property ColumnLayout encryptionArea

//	topPadding: Kirigami.Settings.isMobile ? Kirigami.Units.largeSpacing : Kirigami.Units.largeSpacing * 3
//	bottomPadding: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.largeSpacing * 3
//	leftPadding: bottomPadding
//	rightPadding: leftPadding
//	background: Rectangle {
//		color: secondaryBackgroundColor
//	}

//	contentItem: ColumnLayout {
//		id: mainArea
//		spacing: Kirigami.Units.largeSpacing

//		MobileForm.FormCard {
//			Layout.fillWidth: true
//			contentItem: ColumnLayout {
//				spacing: 0

//				MobileForm.FormCardHeader {
//					title: qsTr("Media")
//				}

//				MobileForm.FormComboBoxDelegate {
//					id: automaticMediaDownloadsDelegate
//					text: qsTr("Automatic Downloads")
//					description: qsTr("Download media automatically")

//					// "FormComboBoxDelegate.indexOfValue()" seems to not work with an array-based
//					// model.
//					// Thus, an own function is used.
//					function indexOf(value) {
//						if (Array.isArray(model)) {
//							return model.findIndex((entry) => entry[valueRole] === value)
//						}

//						return indexOfValue(value)
//					}

//					Component.onCompleted: {
//						// "Kirigami.OverlaySheet" uses a z-index of 101.
//						// In order to see the popup, it needs to have that z-index as well.
//						if (root.sheet) {
//							let comboBox = contentItem.children[2];

//							if (comboBox instanceof Controls.ComboBox) {
//								comboBox.popup.z = 101
//							}
//						}
//                    }
//				}

//				ColumnLayout {
//					visible: mediaOverviewExpansionButton.visible && mediaOverviewExpansionButton.checked
//					spacing: 0

//					Kirigami.Separator {
//						Layout.fillWidth: true
//					}

//					MediaOverview {
//						id: mediaOverview
//						Layout.fillWidth: true
//					}
//				}

//				FormExpansionButton {
//					id: mediaOverviewExpansionButton
//					visible: mediaOverview.totalFilesCount
//					onCheckedChanged: {
//						if (checked) {
//							mediaOverview.selectionMode = false

//							// Display the content of the first tab only on initial loading.
//							// Afterwards, display the content of the last active tab.
//							if (mediaOverview.tabBarCurrentIndex === -1) {
//								mediaOverview.tabBarCurrentIndex = 0
//							}

//							mediaOverview.loadDownloadedFiles()
//						}
//					}
//				}
//			}
//		}

//		MobileForm.FormCard {
//			visible: vCardRepeater.count || vCardRepeater.model.jid === AccountManager.jid
//			Layout.fillWidth: true
//			contentItem: ColumnLayout {
//				id: vCardArea
//				spacing: 0

//				MobileForm.FormCardHeader {
//					title: qsTr("Profile")
//				}

//				Repeater {
//					id: vCardRepeater
//					Layout.fillHeight: true
//				}
//			}
//		}

//		MobileForm.FormCard {
//			Layout.fillWidth: true
//			contentItem: root.encryptionArea
//		}

//		MobileForm.FormCard {
//			// Hide this if there are no items and no header.
//			visible: rosterGoupListView.count || rosterGoupListView.headerItem
//			Layout.fillWidth: true

//			contentItem: ColumnLayout {
//				spacing: 0

//				MobileForm.FormCardHeader {
//					title: qsTr("Labels")
//				}

//				ListView {
//					id: rosterGoupListView
//					model: RosterModel.groups
//					visible: rosterGroupExpansionButton.checked
//					implicitHeight: contentHeight
//					Layout.fillWidth: true
//				}

//				FormExpansionButton {
//					id: rosterGroupExpansionButton
//				}
//			}
//		}

//		MobileForm.FormCard {
//			visible: deviceRepeater.count
//			Layout.fillWidth: true
//			contentItem: ColumnLayout {
//				spacing: 0

//				MobileForm.FormCardHeader {
//					title: qsTr("Connected Devices")
//				}

//				Repeater {
//					id: deviceRepeater
//					Layout.fillHeight: true
//					model: UserDevicesModel {
//						jid: root.jid
//					}
//					delegate: MobileForm.AbstractFormDelegate {
//						visible: deviceExpansionButton.checked
//						background: Item {}
//						contentItem: ColumnLayout {
//							Controls.Label {
//								text: {
//									if (model.name) {
//										if (model.version) {
//											return model.name + " " + model.version
//										}
//										return model.name
//									}
//									return model.resource
//								}
//								textFormat: Text.PlainText
//								wrapMode: Text.WordWrap
//								Layout.fillWidth: true
//							}

//							Controls.Label {
//								text: model.os
//								color: Kirigami.Theme.disabledTextColor
//								font: Kirigami.Theme.smallFont
//								textFormat: Text.PlainText
//								wrapMode: Text.WordWrap
//								Layout.fillWidth: true
//							}
//						}
//					}
//				}

//				FormExpansionButton {
//					id: deviceExpansionButton
//				}
//			}
//		}
//	}

//	function openKeyAuthenticationPage(keyAuthenticationPageComponent, accountJid, chatJid) {
//		if (root.sheet) {
//			root.sheet.close()
//		}

//		var keyAuthenticationPage = openPage(keyAuthenticationPageComponent)
//		keyAuthenticationPage.accountJid = accountJid
//		keyAuthenticationPage.chatJid = chatJid
//	}
//>>>>>>> master
}
