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
//import QtQuick 2.2
//// import QtQuick.Controls 2.14 as Controls
//import Sailfish.Silica 1.0
//// import org.kde.kirigami 2.19 as Kirigami
//// import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import im.kaidan.kaidan 1.0

import "../elements"

SettingsPageBase {
	title: qsTr("About Kaidan")

	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth

	Column {
		id: layout
		anchors.fill: parent

		//FIXME Layout.preferredWidth: 600

		SilicaFlickable {
			width: parent.width

			 Column {
				spacing: 0
				BackgroundItem {
					width: parent.width
					// background: Item {}
					 Row {
						Image {
							source: Utils.getResourcePath("images/kaidan.svg")
							//FIXME Layout.preferredWidth: Kirigami.Units.gridUnit * 5
							// //FIXME Layout.preferredHeight: Kirigami.Units.gridUnit * 5
							width: parent.width
							//FIXME Layout.fillHeight: true
							// Layout.alignment: Qt.AlignCenter
							fillMode: Image.PreserveAspectFit
							mipmap: true
							sourceSize: Qt.size(width, height)
						}

						Column {
							SectionHeader {
								text: Utils.applicationDisplayName + " " + Utils.versionString
								textFormat: Text.PlainText
								wrapMode: Text.WordWrap
								width: parent.width
								horizontalAlignment: Qt.AlignLeft
							}

							Label {
								text: qsTr("User-friendly and modern chat app for every device")
								font.italic: true
								wrapMode: Text.WordWrap
								width: parent.width
								horizontalAlignment: Qt.AlignLeft
							}
						}
					}
				}
			}
		}
		SilicaFlickable {
			width: parent.width

			 Column {
				UrlFormButtonDelegate {
					text: qsTr("Visit website")
					//FIXME description: qsTr("Open Kaidan's website in a web browser")
					icon.source: "globe"
					url: Utils.applicationWebsiteUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("Follow on Mastodon")
					//FIXME description: qsTr("Open Kaidan's Mastodon page in a web browser")
					icon.source: "send-to-symbolic"
					url: Utils.mastodonUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("Donate")
					//FIXME description: qsTr("Support Kaidan's development and infrastructure by a donation")
					icon.source: "emblem-favorite-symbolic"
					url: Utils.donationUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("Report problems")
					//FIXME description: qsTr("Report issues with Kaidan to the developers")
					icon.source: "computer-fail-symbolic"
					url: Utils.issueTrackingUrl
				}

				UrlFormButtonDelegate {
					text: qsTr("View source code")
					//FIXME description: qsTr("View Kaidan's source code online and contribute to the project")
					icon.source: "system-search-symbolic"
					url: Utils.applicationSourceCodeUrl
				}
			}
		}

		SilicaFlickable {
			width: parent.width

			 Column {
				BackgroundItem {
					width: parent.width
					// background: Item {}
					 Column {
						Label {
							text: "GPLv3+ / CC BY-SA 4.0"
							textFormat: Text.PlainText
							wrapMode: Text.WordWrap
							width: parent.width
						}

						Label {
							text: "License"
							font: Kirigami.Theme.smallFont
							color: Kirigami.Theme.secondaryColor
							wrapMode: Text.WordWrap
							width: parent.width
						}
					}
				}

				BackgroundItem {
					width: parent.width
					// background: Item {}
					 Column {
						Label {
							text: "© 2016-2023 Kaidan developers and contributors"
							textFormat: Text.PlainText
							wrapMode: Text.WordWrap
							width: parent.width
						}

						Label {
							text: "Copyright"
							font: Kirigami.Theme.smallFont
							color: Kirigami.Theme.secondaryColor
							wrapMode: Text.WordWrap
							width: parent.width
						}
					}
				}
			}
		}

		Item {
			//FIXME Layout.fillHeight: true
		}
	}
}
