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
	property int tabBarCurrentIndex: 0
    property bool selectionMode: false
    readonly property alias totalFilesCount: fileModel.rowCount
    readonly property alias visibleFilesCount: fileProxyModel.rowCount

	height: Screen.height/3
	Component.onCompleted: loadDownloadedFiles()
	anchors.left: parent.left
	anchors.leftMargin: Theme.horizontalPageMargin
	anchors.right: parent.right
	anchors.rightMargin: Theme.horizontalPageMargin

    SilicaGridView {

		VerticalScrollDecorator {
			flickable: gridView
		}

		id: gridView
        width: parent.width
		height: parent.height
		clip: true

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
				return Theme.itemSizeSmall
            }

            return 0
        }
        header: Column {
            width: parent.width
            Row {
                id: tabBar
                visible: !root.selectionMode
                spacing: 0
				IconButton {
                    id: imageTab
                    width: root.width / 3
					highlighted: tabBarCurrentIndex == 0
					icon.source: "image://theme/icon-m-file-image"
                    onClicked: {
                        tabBarCurrentIndex = 0
                    }
                }
				IconButton {
                    id: videoTab
                    width: root.width / 3
					highlighted: tabBarCurrentIndex == 1
					icon.source: "image://theme/icon-m-file-video"
                    onClicked: {
                        tabBarCurrentIndex = 1
                    }
                }
				IconButton {
                    id: otherTab
                    width: root.width / 3
					highlighted: tabBarCurrentIndex == 2
					icon.source: "image://theme/icon-m-file-other-dark"
                    onClicked: {
						tabBarCurrentIndex = 2
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
					icon.source: "image://theme/icon-m-cancel"
                    onClicked: {
                        root.selectionMode = false
                        fileProxyModel.clearChecked()
                    }
                }

                Label {
                    text: qsTr("%1/%2 selected").arg(fileProxyModel.checkedCount).arg(fileProxyModel.rowCount)
                    width: parent.width - iconClear.width - iconCheckAll.width - iconDeleteChecked.width
					anchors.verticalCenter: parent.verticalCenter
                }

                IconButton {
                    id: iconCheckAll
					enabled: fileProxyModel.checkedCount !== fileProxyModel.rowCount
					icon.source: "image://theme/icon-m-select-all"
                    onClicked: {
                        fileProxyModel.checkAll()
                    }
                }

                IconButton {
                    id: iconDeleteChecked
					icon.source: "image://theme/icon-m-delete"
                    onClicked: {
                        fileProxyModel.deleteChecked()
                        root.selectionMode = false
                    }
                }
            }
			Rectangle {
				color: "transparent"
				width: parent.width
				height: Theme.paddingSmall*2
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
			onFilesDeleted: {
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
				checkable: root.selectionMode
				checked: checkable && model.checkState === Qt.Checked
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

				Image {
					source: model.file.localFileUrl
					fillMode: Image.PreserveAspectCrop
					asynchronous: true
					anchors.fill: parent

					SelectionMarker {
						visible: preview.containsMouse || checked
						checked: preview.checked
						anchors.top: parent.top
						anchors.right: parent.right
						anchors.topMargin: Theme.paddingSmall
						anchors.rightMargin: anchors.topMargin
						onClicked: {
							root.selectionMode = true
							model.checkState = checked ? Qt.Checked : Qt.Unchecked
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
				checkable: root.selectionMode
				checked: checkable && model.checkState === Qt.Checked
				anchors.leftMargin: Theme.horizontalPageMargin
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

                Multimedia.Video {
                    source: model.file.localFileUrl
                    autoPlay: true
                    fillMode: Multimedia.VideoOutput.PreserveAspectCrop
                    anchors.fill: parent
					muted: true

                    SelectionMarker {
                        visible: preview.containsMouse || checked
                        checked: preview.checked
                        anchors.top: parent.top
                        anchors.right: parent.right
						anchors.topMargin: Theme.paddingSmall
                        anchors.rightMargin: anchors.topMargin
                        onClicked: {
                            root.selectionMode = true
							model.checkState = checked ? Qt.Checked : Qt.Unchecked
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

			GridItem {
                id: control
				width: GridView.view.cellWidth
                height: GridView.view.cellHeight
				property bool checkable: root.selectionMode
				property bool checked: checkable && model.checkState === Qt.Checked
				signal toggled

				MouseArea {
					id: selectionArea
					hoverEnabled: true
					acceptedButtons: Qt.NoButton
					width: parent.width
					property bool checked: false

					  Row {
							width: parent.width
							Icon {
								source: model.file.mimeTypeIcon
								sourceSize: Qt.size(Theme.iconSizeMedium, Theme.iconSizeMedium)
							}

							Column {
								width: parent.width - parent.spacing - Theme.iconSizeMedium
								Label {
									text: model.file.name
									width: parent.width
									elide: Qt.ElideRight
									font.bold: true
									font.pixelSize: Theme.fontSizeExtraSmall
								}

								Label {
									width: parent.width
									elide: Qt.ElideRight
									text: model.file.details
									font.pixelSize: Theme.fontSizeExtraSmall
								}
							}
					  }

					  SelectionMarker {
						  visible: selectionArea.containsMouse || checked
						  checked: control.checked
						  onClicked: {
							  root.selectionMode = true
							  control.checked = !control.checked
							  model.checkState = checked ? Qt.Checked : Qt.Unchecked
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
						} else
						{
							control.checked != checked
							model.checkState = checked ? Qt.Checked : Qt.Unchecked
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
