/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

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
		}
	}

	Item {
		Connections {
			target: root.composition.fileSelectionModel

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
					root.composition.send()
					close()
				}
			}
		}
	}
}
