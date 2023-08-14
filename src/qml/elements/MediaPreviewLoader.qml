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
			return false
        case Enums.MessageImage:
        case Enums.MessageAudio:
        case Enums.MessageVideo:
        case Enums.MessageFile:
        case Enums.MessageDocument:
        case Enums.MessageGeoLocation:
            return mediaSource != '' && sourceComponent !== null
		}
	}
	visible: enabled
	sourceComponent: {
		switch (mediaSourceType) {
        case Enums.MessageUnknown:
        case Enums.MessageText:
			return null
        case Enums.MessageImage:
			return imagePreview
        case Enums.MessageAudio:
			return audioPreview
        case Enums.MessageVideo:
			return videoPreview
        case Enums.MessageFile:
        case Enums.MessageDocument:
			return otherPreview
        case Enums.MessageGeoLocation:
			return locationPreview
		}
	}

	//FIXME Layout.fillHeight: item ? item.Layout.fillHeight : false
    width: item ? item.width : nil
	// //FIXME Layout.preferredHeight: item ? item.// Layout.preferredHeight : -1
	//FIXME Layout.preferredWidth: item ? item.Layout.preferredWidth : -1
	//FIXME Layout.minimumHeight: item ? item.Layout.minimumHeight : -1
    //Layout.minimumWidth: item ? item.Layout.minimumWidth : -1
    //Layout.maximumHeight: item ? item.Layout.maximumHeight : -1
	//FIXME Layout.maximumWidth: item ? item.Layout.maximumWidth : -1
	// Layout.alignment: item ? item.Layout.alignment : Qt.AlignCenter
	anchors.margins: item ? item.anchors.margins : 0
	anchors.leftMargin: item ? item.anchors.leftMargin : 0
	anchors.topMargin: item ? item.anchors.topMargin : 0
	anchors.rightMargin: item ? item.anchors.rightMargin : 0
	anchors.bottomMargin: item ? item.anchors.bottomMargin : 0

	Component {
		id: imagePreview

		MediaPreviewImage {
			mediaSource: root.mediaSource
			mediaSourceType: root.mediaSourceType
			message: root.message
			mediaSheet: root.mediaSheet
		}
	}

	Component {
		id: audioPreview

		MediaPreviewAudio {
			mediaSource: root.mediaSource
			mediaSourceType: root.mediaSourceType
			message: root.message
			mediaSheet: root.mediaSheet
		}
	}

	Component {
		id: videoPreview

		MediaPreviewVideo {
			mediaSource: root.mediaSource
			mediaSourceType: root.mediaSourceType
			message: root.message
			mediaSheet: root.mediaSheet
		}
	}

	Component {
		id: otherPreview

		MediaPreviewOther {
			mediaSource: root.mediaSource
		}
	}

	Component {
		id: locationPreview

		MediaPreviewLocation {
			mediaSource: root.mediaSource
			mediaSourceType: root.mediaSourceType
			message: root.message
			mediaSheet: root.mediaSheet
		}
	}
}
