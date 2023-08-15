import QtQuick 2.2
import Sailfish.Silica 1.0

import im.kaidan.kaidan 1.0

import "../elements"

SettingsPageBase {

	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth

    SilicaFlickable {
        width: parent.width

        Column {
           spacing: 0

           PageHeader {
                title: qsTr("About Kaidan")
           }

           Image {
                source: Utils.getResourcePath("images/kaidan.svg")
                width: parent.width
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width, height)
            }

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

            UrlFormButtonDelegate {
                text: qsTr("Visit website")
                description: qsTr("Open Kaidan's website in a web browser")
                icon: "image://theme/icon-m-website"
                url: Utils.applicationWebsiteUrl
            }

            UrlFormButtonDelegate {
                text: qsTr("Follow on Mastodon")
                description: qsTr("Open Kaidan's Mastodon page in a web browser")
                icon: "image://theme/icon-m-forward"
                url: Utils.mastodonUrl
            }

            UrlFormButtonDelegate {
                text: qsTr("Donate")
                description: qsTr("Support Kaidan's development and infrastructure by a donation")
                icon: "image://theme/icon-m-favorite"
                url: Utils.donationUrl
            }

            UrlFormButtonDelegate {
                text: qsTr("Report problems")
                description: qsTr("Report issues with Kaidan to the developers")
                icon : "image://theme/icon-m-computer"
                url: Utils.issueTrackingUrl
            }

            UrlFormButtonDelegate {
                text: qsTr("View source code")
                description: qsTr("View Kaidan's source code online and contribute to the project")
                icon.source: "image://theme/icon-m-search-on-page"
                url: Utils.applicationSourceCodeUrl
            }
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
