// SPDX-FileCopyrightText: 2018 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2019 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * This element is used in the @see SendMediaSheet to display information about a selected file to
 * the user. It shows the file name, file size and a little file icon.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

BackgroundItem {
	id: root

    property url mediaSource
    property int messageSize: Theme.itemSizeLarge // Kirigami.Units.gridUnit * 14
    property QtObject message
    property var file
    property string messageId

	property bool fileAvailable: file.localFilePath && MediaUtilsInstance.localFileAvailable(file.localFilePath)

	width: parent.width
    height: content.height

	// content
	Column {
        id: content
        width: parent.width
        Rectangle {
			id: layout
            color: "transparent"
            width: parent.width
            height: Math.max(fallbackCircle.height, thumbnailIcon.paintedHeight, fileDesc.height)
//            spacing: Theme.paddingSmall

			// left: file icon
            Rectangle {
				id: fallbackCircle
				visible: !file.hasThumbnail
                height: Theme.iconSizeExtraLarge
                width: height
//              radius: height / 2
                color: Theme.highlightBackgroundColor
                opacity: Theme.highlightBackgroundOpacity

                Icon {
                    source: root.fileAvailable ? file.mimeTypeIcon : "image://theme/icon-m-cloud-download"
					smooth: true
                    height: Theme.iconSizeMedium
                    anchors {
						centerIn: parent
					}
				}
            }
            Image {
                id: thumbnailIcon
                visible: file.hasThumbnail
                width: Theme.iconSizeExtraLarge
                height: Theme.iconSizeExtraLarge
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignTop
                source: file.thumbnailSquareUrl
                fillMode: Image.PreserveAspectFit

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: thumbnailIcon.paintedWidth
                        height: thumbnailIcon.paintedHeight

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(thumbnailIcon.width, thumbnailIcon.height)
                            height: width
                            radius: roundedCornersRadius
                        }
                    }
                }

                Icon {
                    source: "image://theme/icon-m-cloud-download"
                    anchors.centerIn: thumbnailIcon
                    anchors.verticalCenterOffset: (thumbnailIcon.paintedHeight - thumbnailIcon.height) / 2
                    anchors.horizontalCenterOffset: (thumbnailIcon.paintedWidth - thumbnailIcon.width) / 2
                    visible: !root.fileAvailable
                }
            }

            // right: file description
            Column {
                id: fileDesc
                anchors.top: parent.top
                x: Math.max(fallbackCircle.width, thumbnailIcon.paintedWidth) + Theme.paddingSmall
                width: parent.width - Math.max(fallbackCircle.width, thumbnailIcon.paintedWidth) - 2*Theme.paddingSmall
                spacing: Theme.paddingSmall

                // file name
                Label {
                    visible: !transferWatcher.isLoading
                    width: parent.width
                    text: file.name
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: 1
                    elide: Text.ElideRight
//                  font.pixelSize: Theme.fontSizeTiny
                }

                // file size
                Label {
                    visible: !transferWatcher.isLoading
                    width: parent.width
                    text: Utils.formattedDataSize(file.size)
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: Theme.secondaryColor
//                  font.pixelSize: Theme.fontSizeTiny
                }
                // progress bar for upload/download status
                Label {
                    visible: transferWatcher.isLoading
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Transfering")
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    font.pixelSize: Theme.fontSizeTiny
                }
                Slider {
                    enabled: false
                    width: parent.width
                    visible: transferWatcher.isLoading
                    value: transferWatcher.progress
                    handleVisible: false
                }
            }
        }

		FileProgressWatcher {
			id: transferWatcher
			fileId: file.fileId
		}
	}

    onClicked:
    {
        if (root.fileAvailable) {
            Qt.openUrlExternally("file://" + file.localFilePath)
        } else if (file.downloadUrl) {
            Kaidan.fileSharingController.downloadFile(root.messageId, root.file)
        }
    }

    onPressAndHold:
    {
        if(contextMenu) {
            root.message.contextMenu.file = root.file
            root.message.contextMenu.message = root.message
            openMenu()
         }
    }
}
