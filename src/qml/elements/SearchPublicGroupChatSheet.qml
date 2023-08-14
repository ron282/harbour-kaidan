// SPDX-FileCopyrightText: 2022 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
// import QtQuick.Controls 2.14 as Controls
import Sailfish.Silica 1.0
// import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0
import PublicGroupChats 1.0 as PublicGroupChats

DockedPanel {
	id: root

	function requestAll() {
		errorLabel.text = "";
		groupChatsManager.requestAll();
	}

	parent: applicationWindow().overlay
	header: SectionHeader {
		text: qsTr("Search public groups (%1)")
				.arg("%1/%2".arg(groupChatsProxy.count).arg(groupChatsModel.count))

		wrapMode: Text.WordWrap
	}

	onSheetOpenChanged: {
		if (sheetOpen) {
			root.forceActiveFocus();
			root.requestAll();
		} else {
			filterField.clear();
		}
	}

	Column {
		enabled: !groupChatsManager.isRunning

		TextField {
			id: filterField

			// selectByMouse: true
			placeholderText: qsTr("Search…")

			onTextChanged: {
				groupChatsProxy.setFilterWildcard(text);
			}
			onActiveFocusChanged: {
				// Force the active focus when it is lost.
				// That is needed because the active focus is changed to EmptyChatPage or RosterPage
				// after opening the public group chat search while being offline (i.e., group chats
				// are not loaded and loadingArea is not shown) for unknown reasons.
				if (!activeFocus && root.sheetOpen) {
					forceActiveFocus()
				}
			}

			width: parent.width
		}

		ListView {
			id: groupChatsField

			clip: true
			model: PublicGroupChats.ProxyModel {
				id: groupChatsProxy

				filterCaseSensitivity: Qt.CaseInsensitive
				filterRole: PublicGroupChats.Model.CustomRole.GlobalSearch
				sortCaseSensitivity: Qt.CaseInsensitive
				sortRole: PublicGroupChats.Model.CustomRole.Users
				sourceModel: PublicGroupChats.Model {
					id: groupChatsModel

					groupChats: groupChatsManager.cachedGroupChats
				}

				Component.onCompleted: {
					sort(0, Qt.DescendingOrder);
				}
			}

			Controls.ScrollBar.vertical: Controls.ScrollBar {
			}

			delegate: Controls.SwipeDelegate {
				width: ListView.view.width - ListView.view.Controls.ScrollBar.vertical.width

				 Row {
					spacing: 12

					Column {
						Avatar {
							width: 48
							height: width
							jid: model.address
							name: model.name
							iconSource: "group"
						}

						Row {
							Icon {
								source: "group"

								//FIXME Layout.preferredWidth: Kirigami.Units.iconSizes.small
								// //FIXME Layout.preferredHeight: Layout.preferredWidth
							}

							Label {
								text: model.users.toString()

								font {
									bold: true
								}
							}
						}
					}

					Column {
						Row {
							Label {
								text: model.name
								wrapMode: Text.Wrap

								font {
									bold: true
								}

								width: parent.width
							}

							Label {
								text: model.languages.join(" ")
								color: "gray"

								// Layout.alignment: Qt.AlignTop
							}
						}

						Label {
							text: model.description
							wrapMode: Text.Wrap

							width: parent.width
						}

						Label {
							text: model.address
							wrapMode: Text.Wrap
							color: "gray"

							width: parent.width
						}
					}
				}

				onClicked: Qt.openUrlExternally(Utils.groupChatUri(model.groupChat))
			}

			PublicGroupChats.SearchManager {
				id: groupChatsManager

				onError: {
					errorLabel.text = qsTr("The public groups could not be retrieved, try again.\n\n%1").arg(error);
				}
			}

			LoadingArea {
				id: loadingArea
				description: qsTr("Downloading…")
				anchors.centerIn: parent

				// background of loadingArea
				Rectangle {
					anchors.fill: loadingArea
					anchors.margins: -8
					radius: roundedCornersRadius
					color: Kirigami.Theme.backgroundColor
					opacity: 0.9
					visible: loadingArea.visible
				}

				Column {
					id: loadingArea
					anchors.centerIn: parent
					visible: groupChatsManager.isRunning
					onVisibleChanged: root.forceActiveFocus()

					BusyIndicator {
						anchors.horizontalCenter: parent
					}

					Label {
						text: "<i>" + qsTr("Loading…") + "</i>"
						color: Kirigami.Theme.textColor
					}
				}
			}

			Item {
				visible: errorLabel.text

				anchors {
					fill: parent
				}

				// background of errorArea
				Rectangle {
					radius: roundedCornersRadius
					color: Kirigami.Theme.backgroundColor
					opacity: 0.9

					anchors {
						fill: errorArea
						margins: -8
					}
				}

				Column {
					id: errorArea

					anchors {
						verticalCenter: parent.verticalCenter
						left: parent.left
						right: parent.right
					}

					Row {
						Icon {
							source: "error"

							//FIXME Layout.preferredWidth: Kirigami.Units.iconSizes.medium
							// //FIXME Layout.preferredHeight: Layout.preferredWidth
						}

						Label {
							id: errorLabel

							wrapMode: Label.WrapAtWordBoundaryOrAnywhere
							color: Kirigami.Theme.textColor

							width: parent.width
						}

						width: parent.width
					}

					Button {
						text: qsTr("Retry");

						onClicked: {
							root.requestAll();
						}

						// Layout.alignment: Qt.AlignCenter
					}
				}
			}

			width: parent.width
			//FIXME Layout.minimumHeight: 300
		}
	}

	function forceActiveFocus() {
		if (!Kirigami.Settings.isMobile && !loadingArea.visible) {
			filterField.forceActiveFocus()
		}
	}
}
