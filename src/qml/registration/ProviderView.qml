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

import im.kaidan.kaidan 1.0

import "../elements"
import "../elements/fields"
import "../settings"

/**
 * This view is used for choosing a provider.
 */
FieldView {
	descriptionText: qsTr("The provider is where your account is located.\nThe selectable providers are hand-picked by our community!")
	imageSource: "provider"

	property string text: customProviderSelected ? field.text : providerListModel.data(comboBox.currentIndex, ProviderListModel.JidRole)
	property string website: providerListModel.data(comboBox.currentIndex, ProviderListModel.WebsiteRole)
	property bool customProviderSelected: providerListModel.data(comboBox.currentIndex, ProviderListModel.IsCustomProviderRole)
	property bool inBandRegistrationSupported: providerListModel.data(comboBox.currentIndex, ProviderListModel.SupportsInBandRegistrationRole)
	property string registrationWebPage: providerListModel.data(comboBox.currentIndex, ProviderListModel.RegistrationWebPageRole)
	property bool shouldWebRegistrationViewBeShown: !customProviderSelected && !inBandRegistrationSupported
	property string outOfBandUrl

	property alias customConnectionSettings: customConnectionSettings

	Column {
		parent: contentArea
		spacing: Kirigami.Units.largeSpacing

		Label {
			text: qsTr("Provider")
		}

        ComboBox {
			id: comboBox
			width: parent.width
			currentIndex: indexOfRandomlySelectedProvider()
			onCurrentIndexChanged: field.text = ""

            menu: ContextMenu {
                id: choices
            }

            ProviderListModel {
             id: providerListMode
            }

            Component.onCompleted:
            {
                for( i=0; i<providerListModel.rowCount(); i++)
                    choices.addItem(providerListModel.data(i, ProviderListModel.DisplayRole));
            }
		}

		Field {
			id: field
			visible: customProviderSelected
			placeholderText: "example.org"
			inputMethodHints: Qt.ImhUrlCharactersOnly

/*			inputField.rightActions: [
				Button {
					icon.source: "preferences-system-symbolic"
					text: qsTr("Connection settings")
					onTriggered: {
						customConnectionSettings.visible = !customConnectionSettings.visible

						if (customConnectionSettings.visible)
							customConnectionSettings.forceActiveFocus()
					}
				}
			]
*/
			onTextChanged: {
				if (outOfBandUrl && customProviderSelected) {
					outOfBandUrl = ""
					removeWebRegistrationView()
				}
			}

			// Focus the customConnectionSettings on confirmation.
			Keys.onPressed: {
				if (customConnectionSettings.visible) {
					switch (event.key) {
					case Qt.Key_Return:
					case Qt.Key_Enter:
						customConnectionSettings.forceActiveFocus()
						event.accepted = true
					}
				}
			}
		}

		CustomConnectionSettings {
			id: customConnectionSettings
			confirmationButton: navigationBar.nextButton
			visible: false
		}

        SilicaFlickable {
			width: parent.width
			//FIXME Layout.fillHeight: true

            Column {
                DetailItem {
					visible: !customProviderSelected && text
                    label: qsTr("Web registration only:")
                    value: inBandRegistrationSupported ? qsTr("No") : qsTr("Yes")
				}

                DetailItem {
					visible: !customProviderSelected && text
                    label: qsTr("Server locations:")
                    value: providerListModel.data(comboBox.currentIndex, ProviderListModel.CountriesRole)
				}

                DetailItem {
					visible: !customProviderSelected && text
                    label: qsTr("Languages:")
                    value: providerListModel.data(comboBox.currentIndex, ProviderListModel.LanguagesRole)
				}

                DetailItem {
					visible: !customProviderSelected && text
                    label: qsTr("Online since:")
                    value: providerListModel.data(comboBox.currentIndex, ProviderListModel.OnlineSinceRole)
				}

                DetailItem {
                    visible: !customProviderSelected && text
                    label: qsTr("Allows to share media up to:")
                    value: providerListModel.data(comboBox.currentIndex, ProviderListModel.HttpUploadSizeRole)
				}

                DetailItem {
					visible: !customProviderSelected && text
                    label: qsTr("Stores shared media up to:")
                    value: providerListModel.data(comboBox.currentIndex, ProviderListModel.MessageStorageDurationRole)
				}
			}
		}

		CenteredAdaptiveHighlightedButton {
			visible: !customProviderSelected
			text: qsTr("Open website")
			onClicked: Qt.openUrlExternally(website)
		}

		CenteredAdaptiveButton {
			visible: !customProviderSelected
			text: qsTr("Copy website address")
			onClicked: Utils.copyToClipboard(website)
		}

		// placeholder
		Item {
			//FIXME Layout.fillHeight: true
		}
	}

	onShouldWebRegistrationViewBeShownChanged: {
		// Show the web registration view for non-custom providers if only web registration is supported or hides the view otherwise.
		if (shouldWebRegistrationViewBeShown)
			addWebRegistrationView()
		else
			removeWebRegistrationView()
	}

	/**
	 * Randomly sets a new provider as selected for registration.
	 */
	function selectProviderRandomly() {
		comboBox.currentIndex = indexOfRandomlySelectedProvider()
	}

	/**
	 * Returns the index of a randomly selected provider for registration.
	 */
	function indexOfRandomlySelectedProvider() {
		return providerListModel.randomlyChooseIndex()
	}
}
