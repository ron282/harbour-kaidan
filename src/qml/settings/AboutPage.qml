/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2022 Kaidan developers and contributors
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
//import QtQuick 2.14
//import QtQuick.Controls 2.14 as Controls
//import QtQuick.Layouts 1.14
//import org.kde.kirigami 2.19 as Kirigami
//import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import im.kaidan.kaidan 1.0

import "../elements"

SettingsPageBase {
	title: qsTr("About Kaidan")

	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth

	ColumnLayout {
		id: layout
		anchors.fill: parent

		Layout.preferredWidth: 600

		MobileForm.FormCard {
			Layout.fillWidth: true

			contentItem: ColumnLayout {
				spacing: 0
				MobileForm.AbstractFormDelegate {
					Layout.fillWidth: true
					background: Item {}
					contentItem: RowLayout {
						Image {
							source: Utils.getResourcePath("images/kaidan.svg")
							Layout.preferredWidth: Kirigami.Units.gridUnit * 5
							Layout.preferredHeight: Kirigami.Units.gridUnit * 5
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.alignment: Qt.AlignCenter
							fillMode: Image.PreserveAspectFit
							mipmap: true
							sourceSize: Qt.size(width, height)
						}

						ColumnLayout {
							Kirigami.Heading {
								text: Utils.applicationDisplayName + " " + Utils.versionString
								textFormat: Text.PlainText
								wrapMode: Text.WordWrap
								Layout.fillWidth: true
								horizontalAlignment: Qt.AlignLeft
							}

							Controls.Label {
								text: qsTr("User-friendly and modern chat app for every device")
								font.italic: true
								wrapMode: Text.WordWrap
								Layout.fillWidth: true
								horizontalAlignment: Qt.AlignLeft
							}
						}
					}
				}
			}
		}
		MobileForm.FormCard {
			Layout.fillWidth: true

			contentItem: ColumnLayout {
				UrlFormButtonDelegate {
					text: qsTr("Visit website")
					description: qsTr("Open Kaidan's website in a web browser")
					icon.name: "globe"
					url: Utils.applicationWebsiteUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("Follow on Mastodon")
					description: qsTr("Open Kaidan's Mastodon page in a web browser")
					icon.name: "send-to-symbolic"
					url: Utils.mastodonUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("Donate")
					description: qsTr("Support Kaidan's development and infrastructure by a donation")
					icon.name: "emblem-favorite-symbolic"
					url: Utils.donationUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("Report problems")
					description: qsTr("Report issues with Kaidan to the developers")
					icon.name: "computer-fail-symbolic"
					url: Utils.issueTrackingUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("View source code")
					description: qsTr("View Kaidan's source code online and contribute to the project")
					icon.name: "system-search-symbolic"
					url: Utils.applicationSourceCodeUrl
				}
			}
		}

		MobileForm.FormCard {
			Layout.fillWidth: true

			contentItem: ColumnLayout {
				MobileForm.AbstractFormDelegate {
					Layout.fillWidth: true
					background: Item {}
					contentItem: ColumnLayout {
						Controls.Label {
							text: "GPLv3+ / CC BY-SA 4.0"
							textFormat: Text.PlainText
							wrapMode: Text.WordWrap
							Layout.fillWidth: true
						}

						Controls.Label {
							text: "License"
							font: Kirigami.Theme.smallFont
							color: Kirigami.Theme.disabledTextColor
							wrapMode: Text.WordWrap
							Layout.fillWidth: true
						}
					}
				}

				MobileForm.AbstractFormDelegate {
					Layout.fillWidth: true
					background: Item {}
					contentItem: ColumnLayout {
						Controls.Label {
							text: "© 2016-2023 Kaidan developers and contributors"
							textFormat: Text.PlainText
							wrapMode: Text.WordWrap
							Layout.fillWidth: true
						}

						Controls.Label {
							text: "Copyright"
							font: Kirigami.Theme.smallFont
							color: Kirigami.Theme.disabledTextColor
							wrapMode: Text.WordWrap
							Layout.fillWidth: true
						}
					}
				}
			}
		}

		Item {
			Layout.fillHeight: true
		}
	}
}
