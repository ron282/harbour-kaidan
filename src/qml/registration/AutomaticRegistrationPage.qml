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

/**
 * This page is used for the automatic registration.
 *
 * Everything that can be automated is automated.
 * The provider is randomly selected.
 * The username and password are randomly generated.
 * Therefore, only custom information requested by the provider is shown.
 * Only required information must be entered to register an account.
 */
RegistrationPage {
	title: qsTr("Register automatically")

	property int maximumAttemptsForRequestingRegistrationFormFromAnotherProvider: 3
	property int remainingAttemptsForRequestingRegistrationFormFromAnotherProvider: maximumAttemptsForRequestingRegistrationFormFromAnotherProvider

	property int maximumRegistrationAttemptsAfterUsernameConflictOccurred: 2
	property int remainingRegistrationAttemptsAfterUsernameConflictOccurred: maximumRegistrationAttemptsAfterUsernameConflictOccurred

	property int maximumRegistrationAttemptsAfterCaptchaVerificationFailedOccurred: 2
	property int remainingRegistrationAttemptsAfterCaptchaVerificationFailedOccurred: maximumRegistrationAttemptsAfterCaptchaVerificationFailedOccurred

	property int maximumRegistrationAttemptsAfterRequiredInformationMissingOccurred: 2
	property int remainingRegistrationAttemptsAfterRequiredInformationMissingOccurred: maximumRegistrationAttemptsAfterRequiredInformationMissingOccurred

	ProviderListModel {
		id: providerListModel
	}

    Column {
		anchors.fill: parent

        SlideshowView {
			id: stackView
			clip: true
            anchors.fill: parent
            delegate: loadingViewComponent
		}
	}

	Component { id: loadingViewComponent; LoadingView {} }

	Component { id: customFormViewComponent; CustomFormViewAutomaticRegistration {}	}

	Component.onCompleted: {
		chooseProviderRandomly()
		chooseUsernameRandomly()
		choosePasswordRandomly()
		requestRegistrationForm()
	}

	Connections {
		target: Kaidan

		function onRegistrationFormReceived(dataFormModel) {
			formModel = dataFormModel
			formFilterModel.sourceModel = dataFormModel

			// If the received registration data form does not contain custom fields, request the registration directly.
			// Otherwise, remove the loading view to show the custom form view.
			if (!customFormFieldsAvailable())
				sendRegistrationForm()
			else
				removeLoadingView()
		}

		function onRegistrationOutOfBandUrlReceived(outOfBandUrl) {
			requestRegistrationFormFromAnotherProvider(qsTr("The provider does currently not support registration via this app."))
		}

		function onRegistrationFailed(error, errorMessage) {
			switch (error) {
			case RegistrationManager.InBandRegistrationNotSupported:
				requestRegistrationFormFromAnotherProvider(errorMessage)
				break
			case RegistrationManager.UsernameConflict:
				if (remainingRegistrationAttemptsAfterUsernameConflictOccurred > 0) {
					remainingRegistrationAttemptsAfterUsernameConflictOccurred--
					// Try to register again with another username on the same provider.
					chooseUsernameRandomly()
					requestRegistrationForm()
				} else {
					remainingRegistrationAttemptsAfterUsernameConflictOccurred = maximumRegistrationAttemptsAfterUsernameConflictOccurred
					requestRegistrationFormFromAnotherProvider(errorMessage)
				}
				break
			case RegistrationManager.CaptchaVerificationFailed:
				if (remainingRegistrationAttemptsAfterCaptchaVerificationFailedOccurred > 0) {
					remainingRegistrationAttemptsAfterCaptchaVerificationFailedOccurred--
					requestRegistrationForm()
					showPassiveNotificationForCaptchaVerificationFailedError()
				} else {
					remainingRegistrationAttemptsAfterCaptchaVerificationFailedOccurred = maximumRegistrationAttemptsAfterCaptchaVerificationFailedOccurred
					requestRegistrationFormFromAnotherProvider(errorMessage)
				}
				break
			case RegistrationManager.RequiredInformationMissing:
				if (remainingRegistrationAttemptsAfterRequiredInformationMissingOccurred > 0 && customFormFieldsAvailable()) {
					remainingRegistrationAttemptsAfterRequiredInformationMissingOccurred--
					requestRegistrationForm()
					showPassiveNotificationForRequiredInformationMissingError(errorMessage)
				} else {
					remainingRegistrationAttemptsAfterRequiredInformationMissingOccurred = remainingRegistrationAttemptsAfterRequiredInformationMissingOccurred
					requestRegistrationFormFromAnotherProvider(errorMessage)
				}
				break
			default:
				requestRegistrationFormFromAnotherProvider(errorMessage)
			}
		}

		function onConnectionErrorChanged() {
			removeLoadingView()
			pageStack.layers.pop()
		}
	}

	// Simulate the pressing of the confirmation button.
	Keys.onPressed: {
		if (stackView.currentItem.registrationButton && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter))
			stackView.currentItem.registrationButton.clicked()
	}

	/**
	 * Adds the loading view to the stack view.
	 */
	function addLoadingView() {
		stackView.push(loadingViewComponent)
	}

	/**
	 * Removes the loading view from the stack view.
	 */
	function removeLoadingView() {
		// Push the custom form view on the stack view if the loading view is the only item on it.
		// That is the case during the first registration form request.
		// When the loading view was pushed on the stack view after submitting custom form fields and the registration fails or a connection error occurs, that loading view is popped to show the custom form view again.
		if (stackView.depth === 1) {
			stackView.push(customFormViewComponent)
			stackView.currentItem.registrationButton.parent = stackView.currentItem.contentArea
		} else {
			stackView.pop()
		}
	}

	/**
	 * Sets a randomly chosen provider for registration.
	 */
	function chooseProviderRandomly() {
		provider = providerListModel.data(providerListModel.randomlyChooseIndex(), ProviderListModel.JidRole)
	}

	/**
	 * Sets a randomly generated username for registration.
	 */
	function chooseUsernameRandomly() {
		username = credentialsGenerator.generateUsername()
	}

	/**
	 * Sets a randomly generated password for registration.
	 */
	function choosePasswordRandomly() {
		password = credentialsGenerator.generatePassword()
	}

	/**
	 * Requests a registration form from another randomly chosen provider if an error occurred.
	 *
	 * That is done multiple times and after a maximum number of attempts, the user has to intervene.
	 *
	 * @param errorMessage message describing the error
	 */
	function requestRegistrationFormFromAnotherProvider(errorMessage) {
		if (remainingAttemptsForRequestingRegistrationFormFromAnotherProvider > 0) {
			remainingAttemptsForRequestingRegistrationFormFromAnotherProvider--
			chooseProviderRandomly()
			requestRegistrationForm()
		} else {
			remainingAttemptsForRequestingRegistrationFormFromAnotherProvider = maximumAttemptsForRequestingRegistrationFormFromAnotherProvider
			showPassiveNotificationForUnknownError(errorMessage)
			popLayerIfNoCustomFormFieldsAvailable()
		}
	}

	/**
	 * Sends the completed registration form and adds the loading view.
	 */
	function sendRegistrationFormAndShowLoadingView() {
		sendRegistrationForm()
		addLoadingView()
	}

	/**
	 * Pops this layer if the received registration form does not contain any custom field.
	 */
	function popLayerIfNoCustomFormFieldsAvailable() {
		if (!customFormFieldsAvailable())
			pageStack.layers.pop()
	}
}
