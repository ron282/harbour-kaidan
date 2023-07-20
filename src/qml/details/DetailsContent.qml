// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import ".."
import "../elements"

SilicaControl {
	id: root

	default property alias __data: mainArea.data
    property DockedPanel sheet
    property string jid
	property alias qrCodePage: qrCodePage
    property alias encryptionArea: encryptionZone.data

//	topPadding: Kirigami.Settings.isMobile ? Kirigami.Units.largeSpacing : Kirigami.Units.largeSpacing * 3
//	bottomPadding: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.largeSpacing * 3
//	leftPadding: bottomPadding
//	rightPadding: leftPadding
//	Rectangle {
//		color: secondaryBackgroundColor
//	}

    Column {
		id: mainArea
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

        SilicaFlickable {
            visible: infoColumnView.count
			width: parent.width
            Column {
				spacing: 0

                SectionHeader {
                    text: qsTr("Profile")
				}

                ColumnView {
                    id: infoColumnView
                    //FIXME Layout.fillHeight: true
					model: VCardModel {
						jid: root.jid
					}
                    delegate: BackgroundItem {
						width: parent.width
                        //FIXME // background: Item {}
                        Column {
                            Label {
								text: Utils.formatMessage(model.value)
								textFormat: Text.StyledText
								wrapMode: Text.WordWrap
								width: parent.width
								onLinkActivated: Qt.openUrlExternally(link)
							}

                            Label {
								text: model.key
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
		}

        SilicaFlickable {
            width: parent.width
            Column {
                id: encryptionZone
            }
        }

        SilicaFlickable {
            visible: deviceColumnView.count
			width: parent.width
            Column {
				spacing: 0

                SectionHeader {
                    text: qsTr("Connected Devices")
				}

                ColumnView {
                    id: deviceColumnView
                    //FIXME Layout.fillHeight: true
					model: UserDevicesModel {
						jid: root.jid
					}
                    delegate: BackgroundItem {
						width: parent.width
                        //FIXME // background: Item {}
                        Column {
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
		}
	}
}
