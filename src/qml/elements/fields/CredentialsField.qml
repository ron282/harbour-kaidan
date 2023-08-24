// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * This is the base for fields which are used to enter credentials.
 */
TextField {
    id: fieldValue
    property bool valid: false
    property alias labelText: fieldValue.label
    property alias credentialsValidator: credentialsValidator
    CredentialsValidator {
        id: credentialsValidator
    }
}

