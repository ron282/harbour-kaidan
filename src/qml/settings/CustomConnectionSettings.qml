// SPDX-FileCopyrightText: 2021 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2023 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"
import "../elements/fields"

Column {
	property alias hostField: hostField
	property alias portField: portField
    width: parent.width

	// The type Item is used because the type Button does not work for buttons of type RoundButton.
	property Item confirmationButton

    TextField {
		id: hostField
        width: parent.width
		label: qsTr("Hostname")
        labelVisible: true
		placeholderText: "xmpp.example.org"
		text: AccountManager.host
		inputMethodHints: Qt.ImhUrlCharactersOnly
//		invalidHintText: qsTr("The hostname must not contain blank spaces")
//		invalidHintMayBeShown: true

		onTextChanged: {
			valid = !text.match(/\s/);
			toggleHintForInvalidText()
		}

		// Focus the portField on confirmation.
		Keys.onPressed: {
			switch (event.key) {
			case Qt.Key_Return:
			case Qt.Key_Enter:
				portField.forceActiveFocus()
				event.accepted = true
			}
		}
	}

    TextField {
        id: portField
        width: parent.width
        text: textFromValue
        label: qsTr("Port")
        inputMethodHints: Qt.ImhDigitsOnly
        acceptableInput: { text == "" || (text >= 0 && text < 65535) }

        property int value

        property string textFromValue: value === AccountManager.portAutodetect ? "" : value
            // By returning the value without taking the locale into account, no digit grouping is applied.
            // Example: For a port number of "one thousand" the text "1000" instead of "1,000" is returned.
    }

	function forceActiveFocus() {
		hostField.forceActiveFocus()
	}
}
