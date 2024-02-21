// SPDX-FileCopyrightText: 2022 Bhavy Airi <airiraghav@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

/**
 * Used to filter the displayed roster items.
 */
Column {
	id: root
    width: parent.width

	property RosterFilterProxyModel rosterFilterProxyModel

	spacing: 0

    TextSwitch {
            id: chatFilteringSwitch
            text: qsTr("Filter by availability")
            description: qsTr("Show only available contacts")
            checked: root.rosterFilterProxyModel.onlyAvailableContactsShown
            onCheckedChanged: root.rosterFilterProxyModel.onlyAvailableContactsShown = checked
    }

    SilicaListView {
        id: accountListView
        model: RosterModel.accountJids
        visible: count > 1
        width: parent.width
        implicitHeight: contentHeight
        header: TextSwitch {
            id: accountFilteringSwitch
            text: qsTr("Filter by accounts")
            description: qsTr("Show only chats of selected accounts")
            enabled: checked
            checked: root.rosterFilterProxyModel.selectedAccountJids.length
            onCheckedChanged: root.rosterFilterProxyModel.selectedAccountJids = []

            // TODO: Remove this once fixed in Kirigami Addons.
            // Add a connection as a work around to reset the switch because
            // "MobileForm.FormSwitchDelegate" does not listen to changes of
            // "root.rosterFilterProxyModel".
            Connections {
                target: root.rosterFilterProxyModel

                function onSelectedAccountJidsChanged() {
                    accountFilteringSwitch.checked = root.rosterFilterProxyModel.selectedAccountJids.length
                }
            }
        }

        delegate: TextSwitch {
            id: accountDelegate
            text: modelData
            checked: root.rosterFilterProxyModel.selectedAccountJids.indexOf(modelData) !== -1
            width: ListView.view.width
            onCheckedChanged: {
                if(checked) {
                    root.rosterFilterProxyModel.selectedAccountJids.push(modelData)
                } else {
                    root.rosterFilterProxyModel.selectedAccountJids.splice(root.rosterFilterProxyModel.selectedAccountJids.indexOf(modelData), 1)
                }
            }

            // TODO: Remove this once fixed in Kirigami Addons.
            // Add a connection as a work around to reset the switch because
            // "MobileForm.FormSwitchDelegate" does not listen to changes of
            // "root.rosterFilterProxyModel".
            Connections {
                target: root.rosterFilterProxyModel

                function onSelectedAccountJidsChanged() {
                    accountDelegate.checked = root.rosterFilterProxyModel.selectedAccountJids.indexOf(modelData) !== -1
                }
            }
        }

        Connections {
            target: RosterModel

            function onAccountJidsChanged() {
                // Remove selected account JIDs that have been removed from the main model.
                const selectedAccountJids = root.rosterFilterProxyModel.selectedAccountJids
                for (var i = 0; i < selectedAccountJids.length; i++) {
                    if (!RosterModel.accountJids.indexOf(selectedAccountJids[i]) !== -1) {
                        root.rosterFilterProxyModel.selectedAccountJids.splice(i, 1)
                    }
                }
            }
        }
    }

    SilicaListView {
        id: groupListView
        model: RosterModel.groups
        visible: count
        width: parent.width
        implicitHeight: contentHeight
        header: TextSwitch {
            id: groupFilteringSwitch
            text: qsTr("Filter by labels")
            description: qsTr("Show only chats with selected labels")
            enabled: checked
            checked: root.rosterFilterProxyModel.selectedGroups.length
            onCheckedChanged: root.rosterFilterProxyModel.selectedGroups = []

            // TODO: Remove this once fixed in Kirigami Addons.
            // Add a connection as a work around to reset the switch because
            // "MobileForm.FormSwitchDelegate" does not listen to changes of
            // "root.rosterFilterProxyModel".
            Connections {
                target: root.rosterFilterProxyModel

                function onSelectedGroupsChanged() {
                    groupFilteringSwitch.checked = root.rosterFilterProxyModel.selectedGroups.length
                }
            }
        }
        delegate: TextSwitch {
            id: groupDelegate
            text: modelData
            checked: root.rosterFilterProxyModel.selectedGroups.indexOf(modelData) !== -1
            width: ListView.view.width
            onCheckedChanged: {
                if (checked) {
                    root.rosterFilterProxyModel.selectedGroups.push(modelData)
                } else {
                    root.rosterFilterProxyModel.selectedGroups.splice(root.rosterFilterProxyModel.selectedGroups.indexOf(modelData), 1)
                }
            }

            // TODO: Remove this once fixed in Kirigami Addons.
            // Add a connection as a work around to reset the switch because
            // "MobileForm.FormSwitchDelegate" does not listen to changes of
            // "root.rosterFilterProxyModel".
            Connections {
                target: root.rosterFilterProxyModel

                function onSelectedGroupsChanged() {
                    groupDelegate.checked = root.rosterFilterProxyModel.selectedGroups.indexOf(modelData) !== -1
                }
            }
        }

        Connections {
            target: RosterModel

            function onGroupsChanged() {
                // Remove selected groups that have been removed from the main model.
                const selectedGroups = root.rosterFilterProxyModel.selectedGroups
                for (var i = 0; i < selectedGroups.length; i++) {
                    const selectedGroup = selectedGroups[i]
                    if (RosterModel.groups.indexOf(selectedGroups[i]) === -1) {
                        root.rosterFilterProxyModel.selectedGroups.splice(i, 1)
                    }
                }
            }
        }
    }
}
