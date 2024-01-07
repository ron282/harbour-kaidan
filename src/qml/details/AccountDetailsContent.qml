// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"
import "../elements/fields"
import "../settings"

DetailsContent {
    id: root

    mediaOverview {
        accountJid: AccountManager.jid
        chatJid: ""
    }
    vCardArea: [
        FormExpansionButton {
            id: vCardExpansionButton
            anchors.right: parent.right
            checked: vCardRepeater.model.unsetEntriesProcessed
            onCheckedChanged: vCardRepeater.model.unsetEntriesProcessed = checked
        }
    ]
    vCardRepeater {
        model: VCardModel {
            jid: root.jid
        }
        delegate: BackgroundItem {
            id: vCardDelegate

            property bool editing: false

            width: parent.width
            height: vCardValueField.height

            TextField {
                id: vCardValueField
                label: model.key
                placeholderText: model.key
                text: model.value
                width: vCardDelegate.width
                rightItem: IconButton {
                    id: vCardConfirmationButton
                    icon.source: editing ? "image://theme/icon-m-right" : "image://theme/icon-s-edit"
                    width: Theme.iconSizeSmall
                    height: width
                    onClicked: {
                        if(editing) {
                            vCardBusyIndicator.visible = true
                            model.value = vCardValueField.text
                            vCardBusyIndicator.visible = false
                            editing = !editing
                        }
                    }
                    BusyIndicator {
                        id: vCardBusyIndicator
                        visible: false
                    }
                }
                onClicked: {
                    vCardDelegate.editing = true
                }
            }
        }
    }

    rosterGroupArea: Column {
        width: parent.width

        SectionHeader {
            text: qsTr("Labels")
        }
        ColumnView {
            id: rosterGroupListView
            model: RosterModel.groups
            visible: true // rosterGroupExpansionButton.checked
            itemHeight: Theme.itemSizeSmall
            delegate: BackgroundItem {
                id: rosterGroupDelegate
                width: parent.width
                onClicked: rosterGroupEditingButton.toggled()
                Row {
                    Label {
                        id: rosterGroupText
                        text: modelData
                        textFormat: Text.PlainText
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        visible: !rosterGroupTextField.visible
                        height: rosterGroupTextField.height
                        width: parent.width - 2*Theme.iconSizeMedium
                        leftPadding: Theme.paddingSmall
                    }
                    TextField {
                        id: rosterGroupTextField
                        text: modelData
                        visible: false
                        width: parent.width - 2*Theme.iconSizeMedium
//                        onAccepted: rosterGroupEditingButton.toggled()
                    }
                    IconButton {
                        id: rosterGroupEditingButton
                        icon.source: "image://theme/icon-s-edit"
                        visible: !rosterGroupText.visible
//                      checked: !rosterGroupText.visible
                        // Ensure that the button can be used within "rosterGroupDelegate"
                        // which acts as an overlay to toggle this button when clicked.
                        // Otherwise, this button would be toggled by "rosterGroupDelegate"
                        // and by this button's own visible area at the same time resulting
                        // in resetting the toggling on each click.
                        onClicked: {
                            if (rosterGroupText.visible) {
                                rosterGroupTextField.visible = true
                                rosterGroupTextField.forceActiveFocus()
                                rosterGroupTextField.selectAll()
                            } else {
                                rosterGroupTextField.visible = false

                                if (rosterGroupTextField.text !== modelData) {
                                    RosterModel.updateGroup(modelData, rosterGroupTextField.text)
                                }
                            }
                        }
                    }
                    IconButton {
                        id: rosterGroupRemovalButton
                        icon.source: "image://theme/icon-splus-delete"
                        onClicked: {
                            rosterGroupTextField.visible = false
                            RosterModel.removeGroup(modelData)
                        }
                    }
                }
            }
        }
    }
    encryptionArea: Column {
        width: parent.width

        Component.onCompleted: {
            // Retrieve the own devices if they are not loaded yet on a mobile device.
            if (!root.sheet && MessageModel.currentAccountJid != root.jid) {
                Kaidan.client.omemoManager.initializeChatRequested(root.jid)
            }

            passwordVerificationField.initialize()
            passwordField.initialize()
        }
        Connections {
            target: root.sheet

            onSheetOpenChanged: {
                if (root.sheet.sheetOpen) {
                    // Retrieve the own devices if they are not loaded yet on a desktop device.
                    if (MessageModel.currentAccountJid != root.jid) {
                        Kaidan.client.omemoManager.initializeChatRequested(root.jid)
                    }

                    passwordVerificationField.initialize()
                    passwordField.initialize()
                    passwordChangeErrorMessage.visible = false
                    connectionSettingsErrorMessage.visible = false
                }
            }
        }

        OmemoWatcher {
            id: omemoWatcher
            jid: root.jid
        }

        SectionHeader {
            text: qsTr("Encryption")
        }

        IconTextSwitch {
            text: qsTr("OMEMO 0")
            description: qsTr("End-to-end encryption with OMEMO 0 ensures that nobody else than you and your chat partners can read or modify the data you exchange.")
            checked: Kaidan.settings.encryption === Encryption.Omemo0
            // The switch is toggled by setting the user's preference on using encryption.
            // Note that 'checked' has already the value after the button is clicked.
            onClicked: {
                if (checked) {
                    Kaidan.settings.encryption = Encryption.Omemo0
                    RosterModel.setItemEncryption(root.jid, Encryption.Omemo0)
                } else {
                    Kaidan.settings.encryption = Encryption.NoEncryption
                    RosterModel.setItemEncryption(root.jid, Encryption.NoEncryption)
                }
            }
        }

        Button {
            preferredWidth: Theme.buttonWidthLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (!omemoWatcher.usableOmemoDevices.length) {
                    if (omemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan <b>your</b> devices")
//                        return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
                    } else if (ownResourcesWatcher.resourcesCount > 1) {
                        return qsTr("<b>Not used on your</b> other devices")
                    }
                } else if (omemoWatcher.authenticatableOmemoDevices.length) {
                    if (omemoWatcher.authenticatableOmemoDevices.length === omemoWatcher.distrustedOmemoDevices.length) {
                        return qsTr("Scan <b>your</b> devices")
//                        return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
                    }

                    return qsTr("Scan <b>your</b> devices")
//                  return qsTr("Scan the QR codes of <b>your</b> devices for maximum security")
                }

                return ""
            }
            icon.source: {
                if (!omemoWatcher.usableOmemoDevices.length) {
                    if (omemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-qr"
                    } else if (ownResourcesWatcher.resourcesCount > 1) {
                        return "image://theme/icon-m-warning"
                    }
                } else if (omemoWatcher.authenticatableOmemoDevices.length) {
                    if (omemoWatcher.authenticatableOmemoDevices.length === omemoWatcher.distrustedOmemoDevices.length) {
                        return "image://theme/icon-m-qr"
                    }

                    return "image://theme/icon-m-qr"
                }

                return ""
            }
            visible: text
            enabled: omemoWatcher.authenticatableOmemoDevices.length
            onClicked: pageStack.push(qrCodePage, { isForOwnDevices: true })

            UserResourcesWatcher {
                id: ownResourcesWatcher
                jid: root.jid
            }
        }
    }

    Component {
        id: contactAdditionSheet
        RosterAddContactSheet {

        }
    }

     Column {
         id: providerArea
         width: parent.width
         visible: providerUrl  || chatSupportList.length || groupChatSupportList.length

         readonly property string providerUrl: {
             const domain = root.jid.split('@')[1]
             const provider = providerListModel.provider(domain)

             return providerListModel.chooseWebsite(provider.websites)
         }

         readonly property var chatSupportList: providerListModel.providerFromBareJid(root.jid).chatSupportList
         readonly property var groupChatSupportList: providerListModel.providerFromBareJid(root.jid).groupChatSupportList

        ProviderListModel {
            id: providerListModel
        }

        ChatSupportSheet {
            id: chatSupportSheet
            chatSupportList: providerArea.chatSupportList
        }

        SectionHeader {
            text: qsTr("Provider")
        }

        ValueButton {
            value: qsTr("Visit website")
            description: qsTr("Open your provider's website in a web browser")
            visible: providerArea.providerUrl
            onClicked: Qt.openUrlExternally(providerArea.providerUrl)
        }

        ValueButton {
            value: qsTr("Copy website address")
            description: qsTr("Copy your provider's web address to the clipboard")
            visible: providerArea.providerUrl
            onClicked: {
                Utils.copyToClipboard(providerArea.providerUrl)
                passiveNotification(qsTr("Website address copied to clipboard"))
            }
        }

        ValueButton {
            value: qsTr("Open support chat")
            description: qsTr("Start chat with your provider's support contact")
            visible: providerArea.chatSupportList.length > 0
            onClicked: {
                if (providerArea.chatSupportList.length === 1) {
                    if (!contactAdditionSheet.sheetOpen) {
                        contactAdditionSheet.jid = providerArea.chatSupportList[0]
                        contactAdditionSheet.nickname = qsTr("Support")
                        root.sheet.close()
                        contactAdditionSheet.open()
                    }
                } else if (!chatSupportSheet.sheetOpen) {
                    root.sheet.close()
                    chatSupportSheet.open()
                }
            }
        }

        ValueButton {
            value: qsTr("Open support group")
            description: qsTr("Join your provider's public support group")
            visible: providerArea.groupChatSupportList.length > 0
            onClicked: {
                if (providerArea.groupChatSupportList.length === 1) {
                    Qt.openUrlExternally(Utils.groupChatUri(providerArea.groupChatSupportList[0]))
                } else {
                    chatSupportSheet.isGroupChatSupportSheet = true

                    if (!chatSupportSheet.sheetOpen) {
                        chatSupportSheet.open()
                    }
                }
            }
        }
    }

     Column {
        visible: Kaidan.serverFeaturesCache.inBandRegistrationSupported
        width: parent.width

        SectionHeader {
            text: qsTr("Password Change")
        }

        Label {
            width: parent.width - 2*Theme.horizontalPageMargin
            leftPadding: Theme.horizontalPageMargin
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            text: qsTr("Change your password. You need to enter the new password on all your other devices!")
        }

        PasswordField {
            id: passwordVerificationField
            label: qsTr("Current password")
            placeholderText: "Enter your current password"
            // invalidHintText: qsTr("Enter correct password")
            visible: true // Kaidan.settings.passwordVisibility !== Kaidan.PasswordVisible
            enabled: !passwordBusyIndicator.visible
            onTextChanged: {
                valid = text === AccountManager.password
                toggleHintForInvalidText()
            }
            EnterKey.onClicked: passwordChangeConfirmationButton.clicked()

            function initialize() {
//                          showPassword = false
//                          invalidHintMayBeShown = false
                text = ""
            }
       }
        PasswordField {
            property bool valid: false
            label: passwordVerificationField.visible ? qsTr("New password") : qsTr("Password")
            id: passwordField
            placeholderText: "Enter your new password"
            //invalidHintText: qsTr("Enter different password to change it")
            //invalidHintMayBeShown: true
            enabled: !passwordBusyIndicator.visible
            onTextChanged: {
                valid = credentialsValidator.isPasswordValid(text) && text !== AccountManager.password
//                              toggleHintForInvalidText()
            }
            EnterKey.onClicked: passwordChangeConfirmationButton.clicked()

            function initialize() {
//                              showPassword = false
                text = passwordVerificationField.visible ? "" : AccountManager.password

                // Avoid showing a hint on initial setting.
//                              invalidHint.visible = false
            }
            CredentialsValidator {
                id: credentialsValidator
            }
            rightItem: IconButton {
                id: passwordChangeConfirmationButton
                icon.source: "image://theme/icon-splus-right"
                visible: !passwordBusyIndicator.visible
                width: icon.width + 2*Theme.paddingMedium
                height: icon.height
                onClicked: {
                    if (passwordVerificationField.visible && !passwordVerificationField.valid) {
                        passwordVerificationField.forceActiveFocus()
                    } else if (!passwordField.valid) {
                        passwordField.forceActiveFocus()
//                          passwordField.toggleHintForInvalidText()
                    } else {
                        passwordBusyIndicator.visible = true
                        Kaidan.client.registrationManager.changePasswordRequested(passwordField.text)
                    }
                }
            }

            BusyIndicator {
                id: passwordBusyIndicator
                anchors.fill: parent
                visible: false
            }
        }

        Label {
            id: passwordChangeErrorMessage
            visible: false
            font.bold: true
            wrapMode: Text.WordWrap
            width: parent.width
            Rectangle {
                color: Theme.errorColor
//                          radius: roundedCornersRadius
            }
        }

        Connections {
            target: Kaidan

            onPasswordChangeFailed : {
                passwordBusyIndicator.visible = false
                passwordChangeErrorMessage.visible = true
                passwordChangeErrorMessage.text = qsTr("Failed to change password: %1").arg(errorMessage)
            }

            onPasswordChangeSucceeded: {
                passwordBusyIndicator.visible = false
                passwordChangeErrorMessage.visible = false
                passiveNotification(qsTr("Password changed successfully"))
            }
        }
    }

     Column {
        visible: Kaidan.settings.passwordVisibility !== Kaidan.PasswordInvisible
        width: parent.width
        spacing: Theme.paddingLarge

        SectionHeader {
            text: qsTr("Password Security")
        }

        Label {
            wrapMode: Text.WordWrap
            width: parent.width - 2*Theme.horizontalPageMargin
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            leftPadding: Theme.horizontalPageMargin
            text: qsTr("Configure this device to not expose your password for changing it or switching to another device. If you want to change your password or use your account on another device later, <b>consider storing the password somewhere else. This cannot be undone!</b>")
        }

        Button {
            text: qsTr("Don't show password as text")
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Kaidan.settings.passwordVisibility === Kaidan.PasswordVisible
            //description: qsTr("Allow to add additional devices using the login QR code but never show the password")
            icon.source: "image://theme/icon-splus-hide-password"
            onClicked: {
                Kaidan.settings.passwordVisibility = Kaidan.PasswordVisibleQrOnly
                passwordField.initialize()
            }
        }

        Button {
            text: qsTr("Don't expose password")
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Kaidan.settings.passwordVisibility !== Kaidan.PasswordInvisible
            //FIXME description: qsTr("Neither allow to add additional devices using the login QR code nor show the password")
            icon.source: "image://theme/icon-s-outline-secure"
            onClicked: {
                const oldPasswordVisibility = Kaidan.settings.passwordVisibility
                Kaidan.settings.passwordVisibility = Kaidan.PasswordInvisible

                // Do not initialize passwordField when the password is already hidden.
                if (oldPasswordVisibility === Kaidan.PasswordVisible) {
                    passwordField.initialize()
                }
            }
        }
    }

     Column {
        width: parent.width

        SectionHeader {
            text: qsTr("Connection")
        }

        Label {
            width: parent.width - 2*Theme.horizontalPageMargin
            leftPadding: Theme.horizontalPageMargin
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            text: qsTr("Configure the hostname and port to connect to (empty fields for default values)")
        }
        Row {
            width: parent.width
            CustomConnectionSettings {
                id: customConnectionSettings
                //confirmationButton: connectionSettingsConfirmationButton
            }
            Button {
                id: connectionSettingsConfirmationButton
                icon.source: "image://theme/icon-m-enter-accept"
                visible: !connectionSettingsBusyIndicator.visible
                // Layout.alignment: Qt.AlignBottom
                onClicked: {
                    if (customConnectionSettings.hostField.text === AccountManager.host && customConnectionSettings.portField.value === AccountManager.port) {
                        connectionSettingsErrorMessage.text = qsTr("Enter different connection settings to change them")
                        connectionSettingsErrorMessage.visible = true
                    } else {
                        connectionSettingsBusyIndicator.visible = true

                        // Reset the error message in case of previous button clicking without changed entered settings.
                        if (Kaidan.connectionError === ClientWorker.NoError) {
                            connectionSettingsErrorMessage.visible = false
                        }

                        if (Kaidan.connectionState === Enums.StateDisconnected) {
                            connectionSettings.logIn()
                        } else {
                            Kaidan.logOut()
                        }
                    }
                }
            }

            BusyIndicator {
                id: connectionSettingsBusyIndicator
                visible: false
            }
        }

        Label {
            id: connectionSettingsErrorMessage
            visible: false
            font.bold: true
            wrapMode: Text.WordWrap
            padding: 10
            width: parent.width
            Rectangle {
                color: Theme.errorColor
//                          radius: roundedCornersRadius
            }
        }

        Connections {
            target: Kaidan

            onConnectionErrorChanged: {
                // Skip connection error changes not invoked via connectionSettings by checking whether connectionSettingsBusyIndicator is visible.
                if (Kaidan.connectionError === ClientWorker.NoError) {
                    connectionSettingsErrorMessage.visible = false
                } else {
                    connectionSettingsErrorMessage.visible = true
                    connectionSettingsErrorMessage.text = qsTr("Connection settings could not be changed: %1").arg(Utils.connectionErrorMessage(Kaidan.connectionError))
                }
            }

            onConnectionStateChanged: {
                // Skip connection state changes not invoked via connectionSettings by checking whether connectionSettingsBusyIndicator is visible.
                if (connectionSettingsBusyIndicator.visible) {
                    if (Kaidan.connectionState === Enums.StateDisconnected) {
                        if (Kaidan.connectionError === ClientWorker.NoError) {
                            connectionSettings.logIn()
                        } else {
                            connectionSettingsBusyIndicator.visible = false
                        }
                    } else if (Kaidan.connectionState === Enums.StateConnected) {
                        connectionSettingsBusyIndicator.visible = false
                        passiveNotification(qsTr("Connection settings changed"))
                    }
                }
            }
        }

        function logIn() {
            AccountManager.host = customConnectionSettings.hostField.text
            AccountManager.port = customConnectionSettings.portField.value
            Kaidan.logIn()
        }

     }

     Column {
        width: parent.width

        SectionHeader {
            text: qsTr("Removal")
        }

        IconTextSwitch {
            id: removalButton
            text: qsTr("Remove from Kaidan")
            description: qsTr("Remove account from this app. Back up your credentials and chat history if needed!")
            icon.source: "image://theme/icon-m-delete"
            onCheckedChanged: contactRemovalCorfirmationButton.visible = !contactRemovalCorfirmationButton.visible
        }

        Button {
            id: contactRemovalCorfirmationButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Confirm")
            visible: false
            onClicked: {
                visible = false
                removalButton.enabled = false
                Kaidan.deleteAccountFromClient()
            }
        }
        IconTextSwitch {
            id: deletionButton
            text: qsTr("Delete completely")
            description: qsTr("Delete account from provider. You will not be able to use your account again!")
            icon.source: "image://theme/icon-m-delete"
            onCheckedChanged: contactDeletionCorfirmationButton.visible = !contactDeletionCorfirmationButton.visible
        }

        Button {
            id: contactDeletionCorfirmationButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Confirm")
            visible: false
            onClicked: {
                visible = false
                removalButton.enabled = false
                Kaidan.deleteAccountFromClientAndServer()
            }
        }
    }
}
