// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
