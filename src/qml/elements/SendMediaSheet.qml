// SPDX-FileCopyrightText: 2018 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

DockedPanel {
	id: root

	property string targetJid
    property MessageComposition composition
    property QtObject chatPage

	signal rejected()
	signal accepted()

    SectionHeader {
		text: qsTr("Share files")
	}

	// First open the file choose to select a file, then open the sheet
	function selectFile() {
		root.composition.fileSelectionModel.selectFile()
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
		if (!root.sheetOpen) {
			root.open()
		}
	}

    onOpenChanged: {
        if (!open) {
			root.composition.fileSelectionModel.clear()
			messageText.text = ""
		}
	}

	Item {
		Connections {
			target: root.composition && root.composition.fileSelectionModel

			function onSelectFileFinished() {
				if (!root.sheetOpen) {
				   root.open()
				}
			}
		}
	}

	Column {
        anchors.horizontalCenter: parent
        anchors.topMargin: Theme.paddingSmall
        anchors.bottomMargin: Theme.paddingSmall
        Label {
			text: qsTr("Choose files")
			visible: fileList.count === 0
		}

		// List of selected files
		ColumnView {
			id: fileList
			model: root.composition.fileSelectionModel

            delegate: ListItem {
				id: delegateRoot

                Row {
					// Icon
					Icon {
                        width: Theme.iconSizeExtraLarge
                        height: width
						source: model.thumbnail
					}

					// spacer
					Item {
					}

					// File name and description
					Column {
						width: parent.width

						Row {
							SectionHeader {
								width: parent.width

                                // level: 3
								text: model.fileName
							}

							Label {
								text: model.fileSize
							}
						}

						TextField {
							width: parent.width

							text: model.description
							placeholderText: qsTr("Enter description…")

							onTextChanged: model.description = text
						}
					}

                    Button {
                        icon.source: "image://theme/icon-splus-remove"
						text: qsTr("Remove file")
						//FIXME display: Controls.AbstractButton.IconOnly
						onClicked: root.composition.fileSelectionModel.removeFile(model.index)
					}
				}
			}
		}

		TextField {
			id: messageText

			width: parent.width
            anchors.topMargin: Theme.paddingLarge

			placeholderText: qsTr("Compose message")
			onFocusChanged: root.composition.body = messageText.text
		}

		// Button row
		Row {
            Button {
				text: qsTr("Add")
                icon.source: "image://theme/icon-m-attach"

				onClicked: root.composition.fileSelectionModel.selectFile()
			}

			Item {
				width: parent.width
			}

            Button {
				text: qsTr("Send")
                icon.source: "image://theme/icon-m-send"
				onClicked: {
					// always (re)set the body in root.composition (it may contain a body from a previous message)
					root.composition.body = messageText.text
					root.composition.send()
					close()
				}
			}
		}
	}
}
