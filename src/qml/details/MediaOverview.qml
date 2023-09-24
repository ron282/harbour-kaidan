// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtMultimedia 5.6 as Multimedia

import im.kaidan.kaidan 1.0

import "../elements"

BackgroundItem {
    id: root

    property alias accountJid: fileModel.accountJid
    property alias chatJid: fileModel.chatJid
    property int tabBarCurrentIndex: -1
    property bool selectionMode: false
    readonly property alias totalFilesCount: fileModel.rowCount
    readonly property alias visibleFilesCount: fileProxyModel.rowCount

    width: parent.width
    Component.onCompleted: loadDownloadedFiles()

    SilicaGridView {
        width: parent.width
        implicitHeight: contentHeight

        cellWidth: {
            switch (root.tabBarCurrentIndex) {
            case 0:
            case 1:
                return root.width / 4
            case 2:
                return width
            }

            return 0
        }
        cellHeight: {
            switch (root.tabBarCurrentIndex) {
            case 0:
            case 1:
                return cellWidth
            case 2:
                return Theme.iconSizeLarge
            }

            return 0
        }
        header: Column {
            ButtonLayout {
                id: tabBar
                visible: !root.selectionMode
                width: parent.width
                height: Theme.itemSizeMedium
                columnSpacing: 0
                Switch {
                    id: imagesTab
                    width: tabBar.width / 3
                    iconSource: "image://theme/icon-m-file-image"
                    checked: true
                    automaticCheck: false
                    onClicked: {
                        tabBarCurrentIndex = 0
                        imageTab.checked = true
                        videoTab.checked = false
                        otherTab.checked = false
                    }
                }
                Switch {
                    id: videoTab
                    width: tabBar.width / 3
                    iconSource: "image://theme/icon-m-file-video"
                    automaticCheck: false
                    onClicked: {
                        tabBarCurrentIndex = 1
                        imageTab.checked = false
                        videoTab.checked = true
                        otherTab.checked = false
                    }
                }
                Switch {
                    id: otherTab
                    width: tabBar.width / 3
                    iconSource: "image://theme/icon-m-file-other-dark"
                    automaticCheck: false
                    onClicked: {
                        tabBarCurrentIndex = 2
                        videoTab.checked = false
                        imageTab.checked = false
                        otherTab.checked = true
                    }
                }
           }

            // tool bar for actions on selected media
            Row {
                visible: root.selectionMode
                anchors {
                    right: parent.right
                    left: parent.left
                }

                IconButton {
                    id: iconClear
                    icon.source: "image://theme/icon-s-checkmark"
                    onClicked: {
                        root.selectionMode = false
                        fileProxyModel.clearChecked()
                    }
                }

                Label {
                    text: qsTr("%1/%2 selected").arg(fileProxyModel.checkedCount).arg(fileProxyModel.rowCount)
                    width: parent.width - iconClear.width - iconCheckAll.width - iconDeleteChecked.width
                }

                IconButton {
                    id: iconCheckAll
                    visible: fileProxyModel.checkedCount !== fileProxyModel.rowCount
                    icon.source: "image://theme/icon-s-group-chat"
                    onClicked: {
                        fileProxyModel.checkAll()
                    }
                }

                IconButton {
                    id: iconDeleteChecked
                    icon.source: "image://theme/icon-s-decline"
                    onClicked: {
                        fileProxyModel.deleteChecked()
                        root.selectionMode = false
                    }
                }
            }
        }
        model: FileProxyModel {
            id: fileProxyModel
            mode: {
                switch (root.tabBarCurrentIndex) {
                case 0:
                    return FileProxyModel.Images
                case 1:
                    return FileProxyModel.Videos
                case 2:
                    return FileProxyModel.Other
                }

                return FileProxyModel.All
            }
            sourceModel: FileModel {
                id: fileModel
            }
//            onFilesDeleted: (files, errors) => {
//                if (errors.length > 0) {
//                    passiveNotification(qsTr("Not all files could be deleted:\n%1").arg(errors[0]))
//                    console.warn("Not all files could be deleted:", errors)
//                }

//                root.loadDownloadedFiles()
//            }
        }
        delegate: Item {/*
            switch (root.tabBarCurrentIndex) {
            case 0:
                return imageDelegate
            case 1:
                return videoDelegate
            case 2:
                return otherDelegate
            }

            return null*/
        }

        Component {
            id: imageDelegate

            SelectablePreview {
                id: preview
//                checkable: root.selectionMode
//                checked: checkable && model.checkState === Qt.Checked
//                onToggled: {
//                    model.checkState = checked ? Qt.Checked : Qt.Unchecked
//                }
                onClicked: {
                    if (root.selectionMode) {
                        if (fileProxyModel.checkedCount === 0) {
                            root.selectionMode = false
                        }
                    } else {
                        Qt.openUrlExternally(model.file.localFileUrl)
                    }
                }
                onPressAndHold: {
                    root.selectionMode = true
                }

                Image {
                    source: model.file.localFileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: parent.availableWidth
                    sourceSize.height: parent.availableHeight
                    anchors.fill: parent

                    SelectionMarker {
                        visible: preview.containsMouse || checked
                        checked: preview.checked
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: anchors.topMargin
                        onClicked: {
                            root.selectionMode = true
                            model.checkState = checkState
                            preview.toggled()
                            preview.clicked()
                        }
                    }
                }
            }
        }

        Component {
            id: videoDelegate

            SelectablePreview {
                id: preview
//                checkable: root.selectionMode
//                checked: checkable && model.checkState === Qt.Checked
//                onToggled: {
//                    model.checkState = checked ? Qt.Checked : Qt.Unchecked
//                }
                onClicked: {
                    if (root.selectionMode) {
                        if (fileProxyModel.checkedCount === 0) {
                            root.selectionMode = false
                        }
                    } else {
                        Qt.openUrlExternally(model.file.localFileUrl)
                    }
                }
                onPressAndHold: {
                    root.selectionMode = true
                }

                Multimedia.Video {
                    source: model.file.localFileUrl
                    autoPlay: true
                    fillMode: Multimedia.VideoOutput.PreserveAspectCrop
                    anchors.fill: parent

                    SelectionMarker {
                        visible: preview.containsMouse || checked
                        checked: preview.checked
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: anchors.topMargin
                        onClicked: {
                            root.selectionMode = true
                            model.checkState = checkState
                            preview.toggled()
                            preview.clicked()
                        }
                    }
                    onStatusChanged: {
                        // Display a thumbnail by playing the first frame and pausing afterwards.
                        if (status === Multimedia.MediaPlayer.Buffered) {
                            pause()
                        }
                    }
                }
            }
        }

        Component {
            id: otherDelegate

            BackgroundItem {
                id: control
                implicitWidth: GridView.view.cellWidth
                implicitHeight: GridView.view.cellHeight
//                autoExclusive: false
//                checkable: root.selectionMode
//                checked: checkable && model.checkState === Qt.Checked
//                topPadding: Theme.paddingLarge
//                bottomPadding: topPadding
                  MouseArea {
                    id: selectionArea
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton

                    SilicaGridView {
                        anchors.fill: parent

                        Icon {
                            source: model.file.mimeTypeIcon
                        }

                        Label {
                            text: model.file.name
                            elide: Qt.ElideRight
                            font.bold: true
                        }

                        Label {
                            text: model.file.details
                        }

                        SelectionMarker {
                            visible: selectionArea.containsMouse || checked
                            checked: control.checked
                            onClicked: {
                                root.selectionMode = true
                                model.checkState = checkState
                                control.toggled()
                                control.clicked()
                            }
                        }
                    }
                }
//                onToggled: {
//                    model.checkState = checked ? Qt.Checked : Qt.Unchecked
//                }
                onClicked: {
                    if (root.selectionMode) {
                        if (fileProxyModel.checkedCount === 0) {
                            root.selectionMode = false
                        }
                    } else {
                        Qt.openUrlExternally(model.file.localFileUrl)
                    }
                }
                onPressAndHold: {
                    root.selectionMode = true
                }
            }
        }
    }

    function loadFiles() {
        fileModel.loadFiles()
    }

    function loadDownloadedFiles() {
        fileModel.loadDownloadedFiles()
    }
}
