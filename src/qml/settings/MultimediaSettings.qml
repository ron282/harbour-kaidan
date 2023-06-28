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
// import QtQuick.Controls 2.14 as Controls
import QtMultimedia 5.6 as Multimedia
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0
import MediaUtils 0.1
// import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

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
					title: qsTr("Select Sources")
				}

				MobileForm.FormComboBoxDelegate {
					id: camerasComboBox
					text: qsTr('Camera')
					displayMode: MobileForm.FormComboBoxDelegate.Dialog
					dialog:Controls.Menu {
						z:60000
						width: parent.width

						id: camerasMenu
						Instantiator {
							id: camerasInstanciator
							model: recorder.cameraModel
							onObjectAdded: camerasMenu.insertItem(index, object)
							onObjectRemoved: camerasMenu.removeItem(object)
							delegate: Controls.MenuItem {
								property string description
								property string camera
								text: description
								onClicked: {
									recorder.mediaSettings.camera = camera
								}
							}
						}
					}

					displayText: camerasInstanciator.model.currentCamera.description
					width: parent.width
				}
				MobileForm.FormComboBoxDelegate {
					id: audioInputsComboBox
					displayMode: MobileForm.FormComboBoxDelegate.Dialog

					text: qsTr('Audio Input')
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

				Kirigami.Separator {
					//FIXME Layout.fillHeight: true
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
				Kirigami.Separator {
					//FIXME Layout.fillHeight: true
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
