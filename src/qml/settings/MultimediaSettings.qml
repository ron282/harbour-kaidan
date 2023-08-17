// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.2
import Sailfish.Silica 1.0
import QtMultimedia 5.6 as Multimedia

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

SettingsPageBase {
	id: root

	property string title: qsTr("Multimedia Settings")

	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth
	MediaRecorder {
		id: recorder
	}

	Column {
		id: layout

		//FIXME Layout.preferredWidth: 600
		anchors.fill: parent

		SilicaFlickable {
			width: parent.width
			 Column {
				spacing: 0

				SectionHeader {
                    text: qsTr("Select Sources")
				}

                ComboBox {
					id: camerasComboBox
                    label: qsTr('Camera')
//					displayMode: MobileForm.FormComboBoxDelegate.Dialog
                    ContextMenu {
						z:60000
						width: parent.width

						id: camerasMenu
						Instantiator {
							id: camerasInstanciator
							model: recorder.cameraModel
							onObjectAdded: camerasMenu.insertItem(index, object)
							onObjectRemoved: camerasMenu.removeItem(object)
                            delegate: MenuItem {
								property string description
								property string camera
								text: description
								onClicked: {
									recorder.mediaSettings.camera = camera
								}
							}
						}
					}

//					displayText: camerasInstanciator.model.currentCamera.description
					width: parent.width
				}
                ComboBox {
					id: audioInputsComboBox
//					displayMode: MobileForm.FormComboBoxDelegate.Dialog

                    label: qsTr('Audio Input')
					dialog:Controls.Menu {
						z:60000
						width: parent.width

						id: audioInputsMenu
						Instantiator {
							id:audioInputsInstanciator
							model: recorder.audioDeviceModel
							onObjectAdded: audioInputsMenu.insertItem(index, object)
							onObjectRemoved: audioInputsMenu.removeItem(object)
							delegate: Controls.MenuItem {
								property string description
								property int index
								text: description
								onClicked: {
									recorder.audioDeviceModel.currentIndex = index
								}
							}
						}
					}

					displayText: audioInputsInstanciator.model.currentAudioDevice.description
					width: parent.width
				}
			}
		}
		SilicaFlickable {
			width: parent.width
			 Column {
				spacing: 0

				SectionHeader {
					title: qsTr("Video Output")
				}
				Controls.ItemDelegate {
					id: item
					width: parent.width
					//FIXME Layout.fillHeight: true

					padding: 1

					hoverEnabled: true
					background: MobileForm.FormDelegateBackground {
						control: item
					}

					 Multimedia.VideoOutput {
						id: output
						source: recorder

						autoOrientation: true

						implicitWidth: contentRect.width < parent.width
									   && contentRect.height
									   < parent.height ? contentRect.width : parent.width
						implicitHeight: contentRect.width < parent.width
										&& contentRect.height
										< parent.height ? contentRect.height : parent.height
					}
				}
			}
		}
		Item {
			//FIXME Layout.fillHeight: true
		}

		SilicaFlickable {
			id: card
			width: parent.width

			 Row {
				spacing: 0
				BackgroundItem {
					width: parent.width
					implicitWidth: (card.width / 3) - 1
					onClicked: recorder.resetSettingsToDefaults()
					 Row {
						Icon {
							source: "kt-restore-defaults"
						}
						Label {
							width: parent.width
							text: qsTr("Reset to defaults")
							wrapMode: Text.Wrap
						}
					}
				}

                Separator {
				}
				BackgroundItem {
					width: parent.width
					implicitWidth: (card.width / 3) - 1
					onClicked: resetUserSettings()
					 Row {
						Icon {
							source: "edit-reset"
						}
						Label {
							width: parent.width
							text: qsTr("Reset User Settings")
							wrapMode: Text.Wrap
						}
					}
				}
                Separator {
				}
				BackgroundItem {
					width: parent.width
					implicitWidth: (card.width / 3) - 1
					onClicked: {
						stack.pop()
						recorder.saveUserSettings()
					}
					 Row {
						Icon {
							source: "document-save"
						}
						Label {
							width: parent.width
							text: qsTr("Save")
							wrapMode: Text.Wrap
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		recorder.type = MediaRecorder.Type.Image
	}
}
