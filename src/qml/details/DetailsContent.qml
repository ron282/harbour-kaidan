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
            visible: false // FIXME

            width: parent.width

            SectionHeader {
                text: qsTr("Media")
            }

            MediaOverview {
                id: mediaOverview
                visible: mediaOverviewExpansionButton.checked
                width: parent.width
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

        Column {
            width: parent.width
            visible: deviceRepeater.count

            SectionHeader {
                text: qsTr("Connected Devices")
            }

            ColumnView {
                id: deviceRepeater
                itemHeight: Theme.itemSizeMedium + Theme.paddingSmall
                model: UserDevicesModel {
                    jid: root.jid
                }
                delegate: Column {
                    width: parent.width - 2*Theme.horizontalPageMargin
                    x: Theme.horizontalPageMargin
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
        Column {
            id: extraContent
            width: parent.width
        }
    }
}
