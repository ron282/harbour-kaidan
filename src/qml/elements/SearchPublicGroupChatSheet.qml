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

    PageHeader {
        id: pageHeader
        title: qsTr("Search public groups (%1)")
                .arg("%1/%2".arg(groupChatsProxy.count).arg(groupChatsModel.count))
    }

    TextField {
        id: filterField

        anchors.top: pageHeader.bottom

        // selectByMouse: true
        placeholderText: qsTr("Search…")

        enabled: !groupChatsManager.isRunning

        onTextChanged: {
            groupChatsProxy.setFilterWildcard(text);
        }

        Keys.onReturnPressed: {
            Qt.inputMethod.hide()
        }

        width: parent.width
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            root.forceActiveFocus();
            root.requestAll();
        } else {
            filterField.clear();
        }
    }

    SilicaListView {
        id: groupChatsField
        anchors.top: filterField.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

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
            width: ListView.view.width
            height: colGroup.height

                Column {
                    id: colGroup
                    width: parent.width                    
//                    Avatar {
//                        width: Theme.iconSizeMedium
//                        height: width
//                        jid: model.address
//                        name: model.name
//                        source: "image://theme/icon-s-group-chat"
//                    }

                    Row {
                        width: parent.width
                        Icon {
                            source: "image://theme/icon-s-group-chat"
                        }
                        Label {
                            width: parent.width - parent.spacing - Theme.iconSizeSmall
                            text: model.name
                            truncationMode: TruncationMode.Elide
                        }
                    }
                    Label {
                        text: model.address
                        truncationMode: TruncationMode.Elide
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Row {
                        width: parent.width
                        Icon {
                            source: "image://theme/icon-m-users"
                            sourceSize: Qt.size(Theme.iconSizeSmall, Theme.iconSizeSmall)
                        }

                        Label {
                            text: model.users.toString()
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                    Row {
                        width: parent.width
                        Label {
                            text: model.name
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeExtraSmall
                            width: parent.width
                        }

                        Label {
                            text: model.languages.join(" ")
                            color: "gray"
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Label {
                        text: model.description
                        wrapMode: Text.Wrap
                        width: parent.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        text: model.address
                        wrapMode: Text.Wrap
                        color: "gray"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        width: parent.width
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
            background.visible: false
            visible: groupChatsManager.isRunning
//          onVisibleChanged: root.forceActiveFocus()
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
    }
}
