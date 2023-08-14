// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * This element is used in the @see SendMediaSheet to display information about a selected audio file to
 * the user. It just displays the audio in a rectangle.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtMultimedia 5.6 as Multimedia
// import QtQuick.Controls 2.14 as Controls
// import org.kde.kirigami 2.19 as Kirigami

import MediaUtils 0.1

MediaPreview {
	id: root

	property alias placeHolder: placeHolder.data

	readonly property alias player: mediaPlayer
	readonly property alias playPauseButton: playPause

	color: 'transparent'

	// //FIXME Layout.preferredHeight: message ? Kirigami.Units.gridUnit * 2.4 : Kirigami.Units.gridUnit * 2.45
	//FIXME Layout.preferredWidth: message ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 20
	//FIXME Layout.maximumWidth: message ? messageSize : -1

	Multimedia.MediaPlayer {
		id: mediaPlayer

		source: root.mediaSource
//		volume: volumePlayer.volume

		onStopped: seek(0)
	}

	Column {
		anchors {
			fill: parent
		}

		Item {
			id: placeHolder

			visible: children.length > 0

			//FIXME Layout.fillHeight: true
			width: parent.width
		}

		Row {
			anchors.topMargin: 6
			anchors.margins: 10
			width: parent.width

            IconButton {
				id: playPause

				icon.source: mediaPlayer.playbackState === Multimedia.MediaPlayer.PlayingState
                           ? 'image://theme/icon-m-pause'
                           : 'image://theme/icon-m-play'

				onClicked: {
					switch (mediaPlayer.playbackState) {
					case Multimedia.MediaPlayer.PlayingState:
						mediaPlayer.pause()
						break
					case Multimedia.MediaPlayer.PausedState:
					case Multimedia.MediaPlayer.StoppedState:
						mediaPlayer.play()
						break
					}
				}
			}

            Slider {
                minimumValue: 0
                maximumValue: mediaPlayer.duration
				value: mediaPlayer.position
				enabled: mediaPlayer.seekable

				width: parent.width

				Row {
					anchors {
						right: parent.right
						top: parent.top
						topMargin: -(parent.height / 2)
					}

					readonly property real fontSize: 7

					Label {
						text: MediaUtilsInstance.prettyDuration(mediaPlayer.position, mediaPlayer.duration)
						font.pointSize: parent.fontSize
						visible: mediaPlayer.duration > 0 && mediaPlayer.playbackState !== Multimedia.MediaPlayer.StoppedState
					}
					Label {
						text: ' / '
						font.pointSize: parent.fontSize
						visible: mediaPlayer.duration > 0 && mediaPlayer.playbackState !== Multimedia.MediaPlayer.StoppedState
					}
					Label {
						text: MediaUtilsInstance.prettyDuration(mediaPlayer.duration)
						visible: mediaPlayer.duration > 0
						font.pointSize: parent.fontSize
					}
				}

                onValueChanged: {
                    if(enabled)
                       mediaPlayer.seek(value)
                }
			}

            IconButton {
                icon.source: 'image://theme/icon-m-document'

				onClicked: Qt.openUrlExternally(root.mediaSource)
			}
		}
	}
}

