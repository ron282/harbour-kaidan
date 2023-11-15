// SPDX-FileCopyrightText: 2018 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2019 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import EmojiModel 0.1

DockedPanel {
	id: root
    width: 100
    height: 50
    dock: DockedPanel.Bottom

	property TextArea textArea
	property string searchedText

    Column {
		anchors.fill: parent

        SilicaGridView {
			id: emojiView
            width: parent.width
            cellWidth: 10
			cellHeight: cellWidth

			boundsBehavior: Flickable.DragOverBounds
			clip: true

			model: EmojiProxyModel {
				sourceModel: EmojiModel {}
				group: hasFavoriteEmojis ? Emoji.Group.Favorites : Emoji.Group.People
			}

            delegate: GridItem {
				width: emojiView.cellWidth
				height: emojiView.cellHeight
				hoverEnabled: true

                Text {
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter

                    font.pixelSize: Theme.fontSizeMedium
					text: model.unicode
				}

				onClicked: {
					emojiView.model.addFavoriteEmoji(model.index);
					textArea.remove(textArea.cursorPosition - searchedText.length, textArea.cursorPosition)
					textArea.insert(textArea.cursorPosition, model.unicode + " ")
					close()
				}
			}

            VerticalScrollDecorator {flickable: emojiView}
		}

		Rectangle {
			visible: emojiView.model.group !== Emoji.Group.Invalid
            color: Theme.highlightColor
		}

		Row {
			visible: emojiView.model.group !== Emoji.Group.Invalid

			ColumnView {
                itemHeight: Theme.itemSizeMedium
				model: ListModel {
                    id: emojiModel
				}

                delegate: BackgroundItem {
                    width: Units.gridUnit * 2.08
					height: width
					hoverEnabled: true
					highlighted: emojiView.model.group === model.group

                    Text {
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter

						font.pointSize: 20
						text: model.label
					}

					onClicked: emojiView.model.group = model.group
				}

                Component.onCompleted: {
                    emojiModel.append({ label: "🔖", group: Emoji.Group.Favorites });
                    emojiModel.append({ label: "🙂", group: Emoji.Group.People });
                    emojiModel.append({ label: "🌲", group: Emoji.Group.Nature });
                    emojiModel.append({ label: "🍛", group: Emoji.Group.Food });
                    emojiModel.append({ label: "🚁", group: Emoji.Group.Activity });
                    emojiModel.append({ label: "🚅", group: Emoji.Group.Travel });
                    emojiModel.append({ label: "💡", group: Emoji.Group.Objects });
                    emojiModel.append({ label: "🔣", group: Emoji.Group.Symbols });
                    emojiModel.append({ label: "🏁", group: Emoji.Group.Flags });
                }
			}
		}
	}

    onOpenChanged: {
        if( open == false) {
            clearSearch()
        }
    }

	function toggle() {
		if (!visible || isSearchActive())
			openWithFavorites()
		else
			close()
	}

	function openWithFavorites() {
		clearSearch()
		open()
	}

	function openForSearch(currentCharacter) {
		searchedText += currentCharacter
		emojiView.model.group = Emoji.Group.Invalid
		open()
	}

	function search() {
		emojiView.model.filter = searchedText.toLowerCase()
	}

	function isSearchActive() {
		return emojiView.model.group === Emoji.Group.Invalid
	}

	function clearSearch() {
		searchedText = ""
		search()
		setFavoritesAsDefaultIfAvailable()
	}

	function setFavoritesAsDefaultIfAvailable() {
		emojiView.model.group = emojiView.model.hasFavoriteEmojis ? Emoji.Group.Favorites : Emoji.Group.People
	}
}
