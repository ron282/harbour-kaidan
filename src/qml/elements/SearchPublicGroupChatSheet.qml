// SPDX-FileCopyrightText: 2022 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0
import PublicGroupChats 1.0 as PublicGroupChats

Page {
	id: root

	function requestAll() {
		errorLabel.text = "";
		groupChatsManager.requestAll();
	}

        SilicaListView {
			id: groupChatsField

            header: 	Column {
                enabled: !groupChatsManager.isRunning

                PageHeader {
                    title: qsTr("Search public groups (%1)")
                            .arg("%1/%2".arg(groupChatsProxy.count).arg(groupChatsModel.count))

                    wrapMode: Text.WordWrap
                }

                TextField {
                    id: filterField

                    // selectByMouse: true
                    placeholderText: qsTr("Search…")

                    onTextChanged: {
                        groupChatsProxy.setFilterWildcard(text);
                    }

                    width: parent.width
                }
            }

            clip: true
			model: PublicGroupChats.ProxyModel {
				id: groupChatsProxy

				filterCaseSensitivity: Qt.CaseInsensitive
                filterRole: PublicGroupChats.Model.GlobalSearch
				sortCaseSensitivity: Qt.CaseInsensitive
                sortRole: PublicGroupChats.Model.Users
				sourceModel: PublicGroupChats.Model {
					id: groupChatsModel

					groupChats: groupChatsManager.cachedGroupChats
				}

				Component.onCompleted: {
					sort(0, Qt.DescendingOrder);
				}
			}

            delegate: BackgroundItem {
                width: SilicaListView.view.width

				 Row {
					spacing: 12

					Column {
						Avatar {
							width: 48
							height: width
							jid: model.address
							name: model.name
//							iconSource: "group"
						}

						Row {
							Icon {
								source: "group"
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

				Column {
                    id: loadingAreaCol
					anchors.centerIn: parent
					visible: groupChatsManager.isRunning

                    BusyLabel {
                        text: "<i>" + qsTr("Loading…") + "</i>"
                    }
				}
			}

            BackgroundItem {
				visible: errorLabel.text

				anchors {
					fill: parent
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
                            source: "image://theme/icon-splus-error"
						}

						Label {
							id: errorLabel
							wrapMode: Label.WrapAtWordBoundaryOrAnywhere
							width: parent.width
						}

						width: parent.width
					}

					Button {
						text: qsTr("Retry");

						onClicked: {
							root.requestAll();
						}
					}
				}
			}

			width: parent.width
        }
}
