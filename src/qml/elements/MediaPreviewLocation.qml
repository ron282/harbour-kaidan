// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * This element is used in the @see SendMediaSheet to display information about a shared location to
 * the user. It just displays the map in a rectangle.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtLocation 5.2

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

MediaPreview {
	id: root

    //FIXME Layout.preferredHeight: message ? messageSize : Kirigami.Units.gridUnit * 18
	//FIXME Layout.preferredWidth: Kirigami.Units.gridUnit * 32
	//FIXME Layout.maximumWidth: message ? messageSize : -1

	Column {
		anchors {
			fill: parent
		}

        Map {
			id: map

			zoomLevel: (maximumZoomLevel - minimumZoomLevel) / 1.2
			center: MediaUtilsInstance.locationCoordinate(root.mediaSource)
            //FIXME copyrightsVisible: false

            plugin: Plugin {
				name: "osm"
                PluginParameter {
					name: "osm.useragent"
					value: Utils.osmUserAgent()
				}
                PluginParameter {
					name: "osm.mapping.providersrepository.address"
					value: "https://autoconfig.kde.org/qtlocation/"
				}
			}

			gesture {
				enabled: false
			}

			//FIXME Layout.fillHeight: true
			width: parent.width

            //FIXME onErrorChanged: {
            //    if (map.error !== Map.NoError) {
            //		console.log("***", map.errorString)
            //    }
            //}

            MapQuickItem {
				id: positionMarker

				coordinate: map.center
				anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height)

                sourceItem: Image {
					source: MediaUtilsInstance.newMediaIconName(Enums.MessageType.MessageGeoLocation)
					height: 48
					width: height
                    //FIXME color: "#e41e25"
					smooth: true
				}
			}

			MouseArea {
				enabled: root.showOpenButton

				anchors {
					fill: parent
				}

				onClicked: {
					if (!Qt.openUrlExternally(root.message.messageBody)) {
						Qt.openUrlExternally('https://www.openstreetmap.org/?mlat=%1&mlon=%2&zoom=18&layers=M'
											 .arg(root.geoLocation.latitude).arg(root.geoLocation.longitude))
					}
				}
			}
		}
    }
}
