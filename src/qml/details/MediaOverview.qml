// SPDX-FileCopyrightText: 2023 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtMultimedia 5.6 as Multimedia

import im.kaidan.kaidan 1.0

import "../elements"

SilicaControl {
    id: root

    property alias accountJid: fileModel.accountJid
    property alias chatJid: fileModel.chatJid
    property int tabBarCurrentIndex: -1
    property bool selectionMode: false
    readonly property alias totalFilesCount: fileModel.rowCount
    readonly property alias visibleFilesCount: fileProxyModel.rowCount

//    leftPadding: 0
//    topPadding: 0
//    rightPadding: 0
//    bottomPadding: 0
    Component.onCompleted: loadDownloadedFiles()
    SilicaGridView {
        implicitHeight: contentHeight
//        boundsMovement: Flickable.StopAtBounds
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
                return Kirigami.Units.largeSpacing * 8
            }

            return 0
        }
        header: Column {
            width: GridView.view.width
            height: implicitHeight
            spacing: 0

            ButtonLayout {
                id: tabBar
                visible: !root.selectionMode
//                spacing: 0

                TextSwitch {
                    id: imagesTab
//                  checkable: true
                    width: tabBar.width / 3
                    Label {
                        text: qsTr("Images")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Controls.Label.AlignHCenter
                        font.bold: parent.checked
                    }
                }

                Separator {
                    id: imagesVideosTabSeparator
                    width: parent.width
                }

                TextSwitch {
                    id: videosTab
//                  checkable: true
                    width: tabBar.width / 3
                    Label {
                        text: qsTr("Videos")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Controls.Label.AlignHCenter
                        font.bold: parent.checked
                    }
                }

                Separator {
                    id: videosOtherTabSeparator
                    width: parent.width
                }

                TextSwitch {
                    id: otherTab
//                  checkable: true
                    width: tabBar.width / 3
                    Label {
                        text: qsTr("Other")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Controls.Label.AlignHCenter
                        font.bold: parent.checked
                    }
                }

                ButtonGroup {
                    id: tabBarGroup
                    buttons: [
                        imagesTab,
                        videosTab,
                        otherTab
                    ]
                    onCheckedButtonChanged: {
                        switch (checkedButton) {
                        case buttons[0]:
                            root.tabBarCurrentIndex = 0
                            break
                        case buttons[1]:
                            root.tabBarCurrentIndex = 1
                            break
                        case buttons[2]:
                            root.tabBarCurrentIndex = 2
                            break
                        default:
                            root.tabBarCurrentIndex = -1
                            break
                        }
                    }
                }

                Binding {
                    target: tabBarGroup
                    property: "checkedButton"
                    value: {
                        if (root.tabBarCurrentIndex < 0 || root.tabBarCurrentIndex >= tabBarGroup.buttons.length) {
                            return null
                        }

                        return tabBarGroup.buttons[root.tabBarCurrentIndex]
                    }
                }
            }

            // tool bar for actions on selected media
            Row {
                visible: root.selectionMode
//                Layout.minimumHeight: tabBar.height
//                Layout.maximumHeight: Layout.minimumHeight
//                Layout.rightMargin: Kirigami.Units.largeSpacing

                IconButton {
                    id: iconClear
                    icon.source: "image:/theme/icon-m-back"
//                    implicitWidth: Kirigami.Units.iconSizes.small
//                    implicitHeight: implicitWidth
                    onClicked: {
                        root.selectionMode = false
                        fileProxyModel.clearChecked()
                    }
                }

                Label {
                    text: qsTr("%1/%2 selected").arg(fileProxyModel.checkedCount).arg(fileProxyModel.rowCount)
                    horizontalAlignment: Qt.AlignLeft
                    width: parent.width - iconClear.width - iconCheckAll.width - iconDeleteChecked.width
                }

                IconButton {
                    id: iconCheckAll
                    visible: fileProxyModel.checkedCount !== fileProxyModel.rowCount
                    icon.source: "edit-select-all-symbolic"
                    onClicked: {
                        fileProxyModel.checkAll()
                    }
                }

                IconButton {
                    id: iconDeleteChecked
                    icon.source: "edit-delete-symbolic"
                    onClicked: {
                        fileProxyModel.deleteChecked()
                        root.selectionMode = false
                    }
                }
            }

            // regular separator
            Separator {
//                implicitHeight: Theme.paddingSmall
                width: parent.width
            }

            // colored marker for current tab selection partly covering the regular separator
            Separator {
//                color: Kirigami.Theme.highlightColor
                visible: !root.selectionMod
                width: parent.width
//                Layout.topMargin: - implicitHeight
/*                Layout.leftMargin: {
                    if (imagesTab.checked) {
                        return 0
                    }

                    if (videosTab.checked) {
                        return imagesTab.width
                    }

                    if (otherTab.checked ) {
                        return imagesTab.width + imagesVideosTabSeparator.width + videosTab.width
                    }
                }
*/
/*               Layout.rightMargin: {
                    if (otherTab.checked) {
                        return 0
                    }

                    if (videosTab.checked ) {
                        return otherTab.width
                    }

                    if (imagesTab.checked ) {
                        return videosTab.width + videosOtherTabSeparator.width + otherTab.width
                    }
                }
*/
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
            onFilesDeleted: (files, errors) => {
                if (errors.length > 0) {
                    passiveNotification(qsTr("Not all files could be deleted:\n%1").arg(errors[0]))
                    console.warn("Not all files could be deleted:", errors)
                }

                root.loadDownloadedFiles()
            }
        }
        delegate: {
            switch (root.tabBarCurrentIndex) {
            case 0:
                return imageDelegate
            case 1:
                return videoDelegate
            case 2:
                return otherDelegate
            }

            return null
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

            Controls.ItemDelegate {
                id: control
                implicitWidth: GridView.view.cellWidth
                implicitHeight: GridView.view.cellHeight
                autoExclusive: false
                checkable: root.selectionMode
                checked: checkable && model.checkState === Qt.Checked
                topPadding: Kirigami.Units.largeSpacing
                bottomPadding: topPadding
                contentItem: MouseArea {
                    id: selectionArea
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton

                    GridLayout {
                        anchors.fill: parent

                        Kirigami.Icon {
                            source: model.file.mimeTypeIcon
                            color: Kirigami.Theme.backgroundColor
                            Layout.row: 0
                            Layout.column: 0
                            Layout.rowSpan: 2
                            Layout.leftMargin: parent.columnSpacing
                            Layout.preferredWidth: parent.height * .8
                            Layout.preferredHeight: Layout.preferredWidth
                        }

                        Controls.Label {
                            text: model.file.name
                            elide: Qt.ElideRight
                            font.bold: true
                            Layout.row: 0
                            Layout.column: 1
                            Layout.fillWidth: true
                        }

                        Controls.Label {
                            text: model.file.details
                            Layout.row: 1
                            Layout.column: 1
                            Layout.fillWidth: true
                        }

                        SelectionMarker {
                            visible: selectionArea.containsMouse || checked
                            checked: control.checked
                            Layout.row: 0
                            Layout.column: 2
                            Layout.rowSpan: 2
                            Layout.rightMargin: parent.columnSpacing * 2
                            onClicked: {
                                root.selectionMode = true
                                model.checkState = checkState
                                control.toggled()
                                control.clicked()
                            }
                        }
                    }
                }
                onToggled: {
                    model.checkState = checked ? Qt.Checked : Qt.Unchecked
                }
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
