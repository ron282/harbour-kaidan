// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is a QR code generated for a specified JID or the own JID.
 *
 * If "isForLogin" is true, a QR code with a login XMPP URI for logging in on
 * another device is generated.

 * Otherwise, a QR code with a Trust Message URI is generated.
 * The Trust Message URI contains key IDs that other clients can use to make
 * trust decisions but they can also just add that contact.
 * If a JID is provided, that JID is used for the URI.
 * Otherwise, the own JID is used.
 */
Image {
    property bool isForLogin: false
    property string jid

    fillMode: Image.PreserveAspectFit

    source: {
		if (width > 0) {
			if (isForLogin) {
                console.log("[QrCode.qml]: generateLoginUriQrCode")
                return qrCodeGenerator.imageToUrl(qrCodeGenerator.generateLoginUriQrCode(width))
			} else if (jid) {
                console.log("[QrCode.qml]: generateContactTrustMessageQrCode")
                return qrCodeGenerator.imageToUrl(qrCodeGenerator.generateContactTrustMessageQrCode(width, jid))
			} else {
                console.log("[QrCode.qml]: generateOwnTrustMessageQrCode")
                return qrCodeGenerator.imageToUrl(qrCodeGenerator.generateOwnTrustMessageQrCode(width))
			}
		}
        return ""
	}

	QrCodeGenerator {
		id: qrCodeGenerator  
	}

	Connections {
		target: MessageModel

		// Update the currently displayed QR code.
		function onKeysChanged() {
			widthChanged()
		}
	}
}
