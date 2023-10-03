// SPDX-FileCopyrightText: 2018 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import im.kaidan.kaidan 1.0
import MediaUtils 0.1

DockedPanel {
	id: root

    dock: Dock.Bottom
    modal: true
    height: content.height
    width: parent.width
    z:1
	property string targetJid
    property string selectedFile
    property MessageComposition composition
    property QtObject chatPage

	signal rejected()
	signal accepted()
    Component {
        id: filePickerPage
        ContentPickerPage {
            onSelectedContentPropertiesChanged: {
                root.composition.fileSelectionModel.addFile(selectedContentProperties.url)
                root.ensureOpen()
            }
        }
    }
    Component {
        id: imagePickerPage
        ImagePickerPage {
            onSelectedContentPropertiesChanged: {
                root.composition.fileSelectionModel.addFile(selectedContentProperties.url)
                root.ensureOpen()
            }
        }
    }
    // First open the file choose to select a file, then open the sheet
	function selectFile() {
        pageStack.push(filePickerPage)
	}

    function selectImage() {
        pageStack.push(imagePickerPage)
    }

    // Open the sheet containing an already known file
	function openWithExistingFile(localPath) {
		root.composition.fileSelectionModel.addFile(localPath)
		root.ensureOpen()
	}

	// Add a known file to the already open sheet
	function addFile(localPath) {
		root.composition.fileSelectionModel.addFile(localPath)
	}

	// Open the sheet if it is not already open
	function ensureOpen() {
        if (!root.open) {
            root.show()
		}
	}

    onOpenChanged: {
        if (!root.open) {
			root.composition.fileSelectionModel.clear()
			messageText.text = ""
		}
	}

	Item {
		Connections {
			target: root.composition && root.composition.fileSelectionModel

			function onSelectFileFinished() {
                if (!root.open) {
                   root.show()
				}
			}
		}
	}
    Rectangle {
        color: Theme.overlayBackgroundColor
        anchors.fill: parent
    }
	Column {
        id: content
        width: parent.width

        anchors {
           topMargin: Theme.paddingSmall
           bottomMargin: Theme.paddingSmall
        }

        SectionHeader {
            text: qsTr("Share files")
        }

        Label {
			text: qsTr("Choose files")
			visible: fileList.count === 0
		}

		// List of selected files
		ColumnView {
			id: fileList
            itemHeight: Theme.itemSizeMedium * 2
            model: root.composition.fileSelectionModel
            width: parent.width

            delegate: ListItem {
				id: delegateRoot

                Row {
                    x:Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium
                    width: parent.width - 2*Theme.horizontalPageMargin

					// Icon
                    Image {
                        width: Theme.iconSizeExtraLarge
                        height: width
                        source: {
                            return model.thumbnailUrl
                        }
					}

					// File name and description
					Column {
                        width: parent.width - Theme.iconSizeExtraLarge - Theme.paddingMedium

                        Label {
                            width: parent.width
                            text: model.fileName
                            maximumLineCount: 1
                            elide: Text.ElideRight
                        }
                        Label {
                            text: Utils.formattedDataSize(model.fileSize)
                            color: Theme.secondaryColor
                        }
						TextField {
							width: parent.width
                            text: model.description
                            placeholderText: qsTr("Enter description…")
							onTextChanged: model.description = text
						}
					}

                    IconButton {
                        icon.source: "image://theme/icon-splus-clear"
						onClicked: root.composition.fileSelectionModel.removeFile(model.index)
					}
				}
			}
		}

		TextField {
			id: messageText

			width: parent.width
            wrapMode: TextEdit.Wrap
			placeholderText: qsTr("Compose message")
			onFocusChanged: root.composition.body = messageText.text
		}

		// Button row
		Row {
            spacing: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
				text: qsTr("Add")
                width: Theme.buttonWidthSmall
                icon.source: "image://theme/icon-m-attach"
                onClicked: pageStack.push(filePickerPage)
			}

            Button {
				text: qsTr("Send")
                width: Theme.buttonWidthSmall
                icon.source: "image://theme/icon-m-send"
				onClicked: {
					// always (re)set the body in root.composition (it may contain a body from a previous message)
					root.composition.body = messageText.text
					root.composition.send()
                    root.hide()
				}
			}
		}
	}
}
