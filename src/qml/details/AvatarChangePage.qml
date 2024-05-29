// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.Gallery 1.0

import im.kaidan.kaidan 1.0

import "../elements"

//Kirigami.Page {
Page {
	id: root

	property string imagePath: Kaidan.avatarStorage.getAvatarUrl(AccountManager.jid)
	property string editPath

//	title: qsTr("Change profile image")
//	Component.onDestruction: openView(accountDetailsSheet, accountDetailsPage)

//	Controls.BusyIndicator {
    BusyIndicator {
		id: busyIndicator
		visible: false
		anchors.centerIn: parent
		width: 60
		height: 60
	}


//	QQD.FileDialog {
//		id: fileDialog
//		title: qsTr("Choose profile image")
//		folder: shortcuts.home

//		selectMultiple: false

//		onAccepted: {
//			imageDoc.path = fileDialog.fileUrl
//			imagePath = fileDialog.fileUrl

//			fileDialog.close()
//		}

//		onRejected: {
//			fileDialog.close()
//		}

//		Component.onCompleted: {
//			visible = false
//		}
//	}

	Component {
		id: fileDialog

        ImagePickerPage {
            title: qsTr("Choose profile image")

            onSelectedContentPropertiesChanged:
            {
                imagePath = selectedContentProperties.filePath
                pageStack.replace(editImage)
            }
        }
	}

	Component {
		id: editImage

        ImageEditDialog {
            cropOnly: true
            anchors.margins: 25
			width: parent.width
            aspectRatio: 1
            aspectRatioType: "square"
            source: imagePath
            target: StandardPaths.pictures+"/"+makeid(8)+".jpg"

            onStatusChanged: {
                if(status == DialogStatus.Closed && editSuccessful)
                    imagePath = target
            }

            function makeid(length) {
                var result = '';
                const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                const charactersLength = characters.length;
                var counter = 0;
                while (counter < length) {
                  result += characters.charAt(Math.floor(Math.random() * charactersLength));
                  counter += 1;
                }
                return result;
            }

        }
	}

//	ColumnLayout {
	Column {
		id: content
		visible: !busyIndicator.visible
//		spacing: 0
//		anchors.fill: parent
		anchors.leftMargin: Theme.horizontalPageMargin
		anchors.rightMargin: Theme.horizontalPageMargin
		anchors.left: parent.left
		anchors.right: parent.right
		width: parent.width

//		KQuickImageEditor.ImageDocument {
//			id: imageDoc
//			path: root.imagePath
//		}

//		KQuickImageEditor.SelectionTool {
//			id: selectionTool
//			width: editImage.paintedWidth
//			height: editImage.paintedHeight
//			x: editImage.horizontalPadding
//			y: editImage.verticalPadding

//			KQuickImageEditor.CropBackground {
//				anchors.fill: parent
//				z: -1
//				insideX: selectionTool.selectionX
//				insideY: selectionTool.selectionY
//				insideWidth: selectionTool.selectionWidth
//				insideHeight: selectionTool.selectionHeight
//			}
//		}
//		onImageChanged: {
//			selectionTool.selectionX = 0
//			selectionTool.selectionY = 0
//			selectionTool.selectionWidth = Qt.binding(() => selectionTool.width)
//			selectionTool.selectionHeight = Qt.binding(() => selectionTool.height)
//		}


        PageHeader {
            title: qsTr("Choose profile image")
        }


        Image {
            id: imageDoc
            source: imagePath
            width: parent.width
            height: width
            fillMode: Image.PreserveAspectCrop;   
        }

		Column {
			width: parent.width
			spacing: Theme.paddingSmall
			// Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
			//FIXME Layout.maximumWidth: largeButtonWidth

			CenteredAdaptiveButton {
				text: qsTr("Open image…")
//				onClicked: fileDialog.open()
				onClicked: pageStack.push(fileDialog)
			}

			CenteredAdaptiveButton {
				text: qsTr("Remove current profile image")
				visible: root.imagePath
				onClicked: Kaidan.client.vCardManager.changeAvatarRequested()
			}

			CenteredAdaptiveHighlightedButton {
				text: qsTr("Save selection")
				visible: root.imagePath
				onClicked: {
//					imageDoc.crop(
//						selectionTool.selectionX / editImage.ratioX,
//						selectionTool.selectionY / editImage.ratioY,
//						selectionTool.selectionWidth / editImage.ratioX,
//						selectionTool.selectionHeight / editImage.ratioY
//					)

					Kaidan.client.vCardManager.changeAvatarUrlRequested(imageDoc.source)
					busyIndicator.visible = true
				}
			}
		}
	}

	Connections {
		target: Kaidan

//		function onAvatarChangeSucceeded() {
		onAvatarChangeSucceeded: {
			busyIndicator.visible = false
			// TODO: Show error message if changing did not succeed
            pageStack.pop()
		}
	}
}
