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

/**
 * This element is used in the @see SendMediaSheet to display information about a selected audio file to
 * the user. It just displays the audio in a rectangle.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
// import QtQuick.Controls 2.14 as Controls
import QtMultimedia 5.6 as Multimedia
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
		volume: volumePlayer.volume

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
						   ? 'media-playback-pause-symbolic'
						   : 'media-playback-start-symbolic'

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
                icon.source: 'document-open-symbolic'

				onClicked: Qt.openUrlExternally(root.mediaSource)
			}
		}
	}
}

