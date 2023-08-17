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

	property RosterFilterProxyModel rosterFilterProxyModel

	spacing: 0

    SilicaListView {
		id: accountListView
		model: RosterModel.accountJids
		implicitWidth: 570
		implicitHeight: contentHeight
        anchors.left: parent.left
        anchors.right: parent.right
        header: BackgroundItem {
            width: SilicaListView.view.width
            TextSwitch {
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

                    onSelectedAccountJidsChanged: {
						accountFilteringSwitch.checked = root.rosterFilterProxyModel.selectedAccountJids.length
					}
				}
			}
		}
        delegate: TextSwitch {
			id: accountDelegate
			text: modelData
			checked: root.rosterFilterProxyModel.selectedAccountJids.includes(modelData)
            width: SilicaListView.view.width
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

                onSelectedAccountJidsChanged: {
					accountDelegate.checked = root.rosterFilterProxyModel.selectedAccountJids.includes(modelData)
				}
			}
		}

		Connections {
			target: RosterModel

            onAccountJidsChanged: {
				// Remove selected account JIDs that have been removed from the main model.
				const selectedAccountJids = root.rosterFilterProxyModel.selectedAccountJids
                for (var i = 0; i < selectedAccountJids.length; i++) {
					if (!RosterModel.accountJids.includes(selectedAccountJids[i])) {
						root.rosterFilterProxyModel.selectedAccountJids.splice(i, 1)
					}
				}
			}
		}
	}

    Separator {
        visible: false
	}

    SilicaListView {
		id: groupListView
		model: RosterModel.groups
		implicitWidth: 570
		implicitHeight: contentHeight
        anchors.left: parent.left
        anchors.right: parent.right
        header: BackgroundItem {
            width: SilicaListView.view.width
            TextSwitch {
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

                    onSelectedGroupsChanged: {
						groupFilteringSwitch.checked = root.rosterFilterProxyModel.selectedGroups.length
					}
				}
			}
		}
        delegate: TextSwitch {
			id: groupDelegate
			text: modelData
			checked: root.rosterFilterProxyModel.selectedGroups.includes(modelData)
            width: SilicaListView.view.width
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

                onSelectedGroupsChanged: {
					groupDelegate.checked = root.rosterFilterProxyModel.selectedGroups.includes(modelData)
				}
			}
		}

		Connections {
			target: RosterModel

            onGroupsChanged: {
				// Remove selected groups that have been removed from the main model.
				const selectedGroups = root.rosterFilterProxyModel.selectedGroups
                for (var i = 0; i < selectedGroups.length; i++) {
					const selectedGroup = selectedGroups[i]
                    if (!RosterModel.groupsList.includes(selectedGroups[i])) {
						root.rosterFilterProxyModel.selectedGroups.splice(i, 1)
					}
				}
			}
		}
	}
}
