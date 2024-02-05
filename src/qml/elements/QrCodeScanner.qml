// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtMultimedia 5.6

import im.kaidan.kaidan 1.0

/**
 * This is a scanner for QR codes which displays the camera input.
 */
Item {
	id: root

	property bool cameraEnabled: false
	property Camera camera
	property alias filter: filter
//    property alias zoomSliderArea: zoomSliderArea
	property bool cornersRounded: true

	// camera with continuous focus in the center of the video
	Camera {
		id: camera
        focus.focusMode: Camera.FocusContinuous
        focus.focusPointMode: Camera.FocusPointCenter

		// Show camera input if this page is visible and the camera enabled.
		cameraState: {
			if (visible && cameraEnabled)
				return Camera.ActiveState
			return Camera.LoadedState
		}

		Component.onCompleted: {
 //           filter.setCameraDefaultVideoFormat(camera);
		}
	}

	// filter which converts the video frames to images and decodes a containing QR code
	QrCodeScannerFilter {
		id: filter

		onUnsupportedFormatReceived: {
            pageStack.pop()
			passiveNotification(qsTr("The camera format '%1' is not supported.").arg(format))
		}
	}

	// video output from the camera which is shown on the screen and decoded by a filter
	VideoOutput {
//		visible: camera.cameraStatus === Camera.ActiveStatus
		fillMode: VideoOutput.PreserveAspectCrop
		source: camera
        autoOrientation: false
        orientation: 0
        filters: [filter]
//        Rectangle {
//            color: "transparent"
//            border.color: secondaryBackgroundColor
//            border.width: radius * 0.3
//            radius: cameraStatusArea.radius * 1.5
//            anchors.fill: parent
//            anchors.margins: - border.width
//        }

//        Rectangle {
//            id: zoomSliderArea
//            color: primaryBackgroundColor
//            opacity: 0.9
//            radius: relativeRoundedCornersRadius(width, height) * 2
//            width: parent.width - Theme.paddingLarge * 4
//            height: Theme.paddingLarge * 4
//            anchors.bottom: parent.bottom
//            anchors.bottomMargin: Theme.paddingLarge * 2
//            anchors.horizontalCenter: parent.horizontalCenter

//            Slider {
//                id: zoomSlider
//                value: 1
//                minimumValue: 1
//                maximumValue: 3
//                width: parent.width - Theme.paddingLarge * 3
//                anchors.centerIn: parent
//            }
//        }
	}

	// hint for camera issues

    Label {
		visible: cameraEnabled && text !== ""
        // icon.source: "camera-video-symbolic"
        // type: Kirigami.MessageType.Warning
		anchors.centerIn: parent
        width: Math.min(Theme.buttonWidthLarge, parent.width)
        height: parent.height

		text: {
			switch (camera.availability) {
			case Camera.Unavailable:
			case Camera.ResourceMissing:
				// message to be shown if no camera can be found
				return qsTr("There is no camera available.")
			case Camera.Busy:
				// message to be shown if the found camera is not usable
				return qsTr("Your camera is busy.\nTry to close other applications using the camera.")
			default:
				// no message if no issue could be found
				return ""
			}
		}
	}

	// This timer is used to reload the camera device in case it is not available at the time of
	// creation.
	// Reloading is needed if the camera device is not plugged in or disabled.
	// That approach ensures that a camera device is even detected again after plugging it out and
	// plugging it in while the scanner is used.
	//
//	Timer {
//		id: reloadingCameraTimer
//		interval: Kirigami.Units.veryLongDuration
//		onTriggered: {
//			root.camera.destroy()
//			cameraComponent.createObject()
//		}
//	}
}
