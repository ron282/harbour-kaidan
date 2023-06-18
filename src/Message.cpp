/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
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

#include "Algorithms.h"
#include "MediaUtils.h"
#include "Message.h"
#include <QXmppBitsOfBinaryContentId.h>
#include <QXmppBitsOfBinaryData.h>
#include <QXmppBitsOfBinaryDataList.h>
#include <QXmppE2eeMetadata.h>
#include <QXmppFileMetadata.h>
#include <QXmppOutOfBandUrl.h>
#include <QXmppThumbnail.h>

#include <QStringBuilder>

#include <QXmppHttpFileSource.h>
#include <QXmppEncryptedFileSource.h>

#if defined (SFOS)

bool FileHash::operator==(const FileHash &o) const
{
	return 
		dataId == o.dataId &&
		hashType == o.hashType &&
		hashValue == o.hashValue;
}

bool HttpSource::operator==(const HttpSource &o) const
{
	return
		fileId == o.fileId &&
		url == o.url;
}

bool EncryptedSource::operator==(const EncryptedSource &o) const
{
	return 
		fileId == o.fileId &&
		url == o.url && 
		cipher == o.cipher &&
		key == o.key &&
		iv == o.iv &&
		encryptedDataId == o.encryptedDataId &&
		encryptedHashes == o.encryptedHashes;
}

bool File::operator==(const File &o) const
{
	return 
		id == o.id &&
	 	fileGroupId == o.fileGroupId &&
		name == o.name &&
		description == o.description &&
		mimeType == o.mimeType &&
		size == o.size &&
	 	lastModified == o.lastModified &&
		disposition == o.disposition &&
	 	localFilePath == o.localFilePath &&
		hashes == o.hashes &&
	 	thumbnail == o.thumbnail &&
		httpSources == o.httpSources &&
		encryptedSources == o.encryptedSources;
}

bool MessageReaction::operator==(const MessageReaction &o) const
{
	return latestTimestamp == o.latestTimestamp &&
			emojis == o.emojis;
}

bool Message::operator==(const Message &m) const
{
	return 
		id == m.id &&
		to == m.to &&
		from == m.from &&
		body == m.body &&
		stamp == m.stamp && 
		isSpoiler == m.isSpoiler &&
		spoilerHint == m.spoilerHint &&
		marker == m.marker &&
		markerId == m.markerId &&
		replaceId == m.replaceId &&
		originId == m.originId &&
		stanzaId == m.stanzaId &&
		fileGroupId == m.fileGroupId &&
		files == m.files &&
		receiptRequested == m.receiptRequested &&
		reactions == m.reactions && 
		encryption == m.encryption &&
		senderKey == m.senderKey && 
		isOwn == m.isOwn &&
		isEdited == m.isEdited &&
		deliveryState == m.deliveryState &&
		errorText == m.errorText;
}

bool Message::operator!=(const Message &m) const
{
	return !(*this == m);
}

#endif

QXmppHash FileHash::toQXmpp() const
{
	QXmppHash hash;
	hash.setAlgorithm(hashType);
	hash.setHash(hashValue);
	return hash;
}

QXmppHttpFileSource HttpSource::toQXmpp() const
{
	QXmppHttpFileSource source;
	source.setUrl(url);
	return source;
}

QXmppEncryptedFileSource EncryptedSource::toQXmpp() const
{
	QXmppHttpFileSource encryptedHttpSource;
	encryptedHttpSource.setUrl(url);

	QXmppEncryptedFileSource source;
	source.setHttpSources({encryptedHttpSource});
	source.setCipher(cipher);
	source.setIv(iv);
	source.setKey(key);
	source.setHashes(transform(encryptedHashes, [](const auto &fileHash) {
		return fileHash.toQXmpp();
	}));
	return source;
}

QXmppFileShare File::toQXmpp() const
{
	QXmppFileMetadata metadata;
	metadata.setFilename(name);
	metadata.setDescription(description);
	metadata.setMediaType(mimeType);
	metadata.setHashes(transform(hashes, [](const FileHash &fileHash) {
		return fileHash.toQXmpp();
	}));
	metadata.setLastModified(lastModified);
	metadata.setMediaType(mimeType);
	metadata.setSize(size);

	QXmppThumbnail thumb;
	thumb.setMediaType(QMimeDatabase().mimeTypeForData(thumbnail));
	thumb.setUri(QXmppBitsOfBinaryData::fromByteArray(thumbnail).cid().toCidUrl());
	metadata.setThumbnails({thumb});

	QXmppFileShare fs;
	fs.setDisposition(disposition);
	fs.setMetadata(metadata);
	fs.setHttpSources(transform(httpSources, [](const HttpSource &fileSource) {
		return fileSource.toQXmpp();
	}));
	fs.setEncryptedSourecs(transform(encryptedSources, [](const EncryptedSource &fileSource) {
		return fileSource.toQXmpp();
	}));
	return fs;
}

QImage File::thumbnailSquareImage() const
{
	auto image = QImage::fromData(thumbnail);
	auto length = std::min(image.width(), image.height());
	QImage croppedImage(QSize(length, length), image.format());

	auto delX = (image.width() - length) / 2;
	auto delY = (image.height() - length) / 2;

	for (int x = 0; x < length; x++) {
		for (int y = 0; y < length; y++) {
			croppedImage.setPixel(x, y, image.pixel(x + delX, y + delY));
		}
	}
	return croppedImage;
}

QUrl File::downloadUrl() const
{
	if (!httpSources.isEmpty()) {
		return httpSources.front().url;
	}
	// don't use encrypted source urls (can't be opened externally)
	return {};
}

#if defined(SFOS)
Enums::MessageType File::type() const
#else
MessageType File::type() const
#endif
{
	return MediaUtils::messageType(mimeType);
}

QXmppMessage Message::toQXmpp() const
{
	QXmppMessage msg;
	msg.setId(id);
	msg.setTo(to);
	msg.setFrom(from);
	msg.setBody(body);
	msg.setStamp(stamp);
	msg.setIsSpoiler(isSpoiler);
	msg.setSpoilerHint(spoilerHint);
	msg.setMarkable(true);
	msg.setMarker(marker);
	msg.setMarkerId(markerId);
	msg.setReplaceId(replaceId);
	msg.setOriginId(originId);
	msg.setStanzaId(stanzaId);
	msg.setReceiptRequested(receiptRequested);

	// attached files
	msg.setSharedFiles(transform(files, [](const File &file) {
		return file.toQXmpp();
	}));

	// attach data for thumbnails
	msg.setBitsOfBinaryData(transform(files, [](const File &file) {
		return QXmppBitsOfBinaryData::fromByteArray(file.thumbnail);
	}));

	// compat for clients without Stateless File Sharing
	msg.setOutOfBandUrls(transformFilter(files, [](const File &file) -> std::optional<QXmppOutOfBandUrl> {
		if (file.httpSources.empty()) {
			return {};
		}

		QXmppOutOfBandUrl data;
		data.setUrl(file.httpSources.front().url.toString());
		data.setDescription(file.description.value_or(QString()));
		return data;
	}));

	return msg;
}

QString Message::previewText() const
{
	if (isSpoiler) {
		if (spoilerHint.isEmpty()) {
			return tr("Spoiler");
		}
		return spoilerHint;
	}

	if (files.empty()) {
		return body;
	}

	// Use first file for detection (could be improved with more complex logic)
	auto mediaType = MediaUtils::messageType(files.front().mimeType);
	auto text = MediaUtils::mediaTypeName(mediaType);

	if (!body.isEmpty()) {
		return text % QStringLiteral(": ") % body;
	}
	return text;
}
