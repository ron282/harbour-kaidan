// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtPositioning 5.2 as Positioning

import im.kaidan.kaidan 1.0
import MediaUtils 0.1

Loader {
	id: root

	property url mediaSource
	property int mediaSourceType
	property bool showOpenButton
	property QtObject message
	property QtObject mediaSheet

	enabled:  {
		switch (mediaSourceType) {
        case Enums.MessageUnknown:
        case Enums.MessageText:
        case Enums.MessageFile:
        case Enums.MessageDocument:
			return false;
        case Enums.MessageImage:
        case Enums.MessageAudio:
        case Enums.MessageVideo:
        case Enums.MessageGeoLocation:
			return mediaSheet
		}
	}
	visible: enabled
	sourceComponent: {
		switch (mediaSourceType) {
        case Enums.MessageUnknown:
        case Enums.MessageText:
        case Enums.MessageFile:
        case Enums.MessageDocument:
			return null
        case Enums.MessageImage:
        case Enums.MessageAudio:
        case Enums.MessageVideo:
			return newMedia
        case Enums.MessageGeoLocation:
			return newMediaLocation
		}
	}

	//FIXME Layout.fillHeight: item ? item.Layout.fillHeight : false
    //width: item ? item.width : null
	// //FIXME Layout.preferredHeight: item ? item.// Layout.preferredHeight : -1
	//FIXME Layout.preferredWidth: item ? item.Layout.preferredWidth : -1
	//FIXME Layout.minimumHeight: item ? item.Layout.minimumHeight : -1
    //FIXME Layout.minimumWidth: item ? item.Layout.minimumWidth : -1
    //FIXME Layout.maximumHeight: item ? item.Layout.maximumHeight : -1
	//FIXME Layout.maximumWidth: item ? item.Layout.maximumWidth : -1
	// Layout.alignment: item ? item.Layout.alignment : Qt.AlignCenter
	anchors.margins: item ? item.anchors.margins : 0
	anchors.leftMargin: item ? item.anchors.leftMargin : 0
	anchors.topMargin: item ? item.anchors.topMargin : 0
	anchors.rightMargin: item ? item.anchors.rightMargin : 0
	anchors.bottomMargin: item ? item.anchors.bottomMargin : 0

	Component {
		id: newMedia

		NewMedia {
			mediaSourceType: root.mediaSourceType
			message: root.message
			mediaSheet: root.mediaSheet

			onMediaSourceChanged: {
				root.mediaSheet.source = mediaSource
			}
		}
	}

	Component {
		id: newMediaLocation

		NewMediaLocation {
			mediaSourceType: root.mediaSourceType
			message: root.message
			mediaSheet: root.mediaSheet

			onMediaSourceChanged: {
				root.mediaSheet.source = mediaSource
			}
		}
	}
}
