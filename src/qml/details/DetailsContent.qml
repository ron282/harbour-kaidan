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
}
