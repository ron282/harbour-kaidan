// SPDX-FileCopyrightText: 2019 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2022 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2022 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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

#include <QFileInfo>
#include <QStringBuilder>

#include <QXmppHttpFileSource.h>
#include <QXmppEncryptedFileSource.h>

#if defined (SFOS)
#include "QmlUtils.h"
#include <QBuffer>

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
//        thumbnail == o.thumbnail &&
		httpSources == o.httpSources &&
		encryptedSources == o.encryptedSources;
}

QUrl File::getHttpSource() const
{
    if(httpSources.count() > 0)
        return httpSources.constBegin()->url;
    else
        return QUrl {};
}
bool MessageReaction::operator==(const MessageReaction &o) const
{
    return deliveryState == o.deliveryState &&
            emoji == o.emoji;
}

bool MessageReactionSender::operator==(const MessageReactionSender &other) const
{
    return 	latestTimestamp == other.latestTimestamp &&
            reactions == other.reactions;
}

bool Message::operator==(const Message &m) const
{
#warning FIXME
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
        encryption == m.encryption &&
		senderKey == m.senderKey && 
		isOwn == m.isOwn &&
		deliveryState == m.deliveryState &&
		errorText == m.errorText;
}

bool Message::operator!=(const Message &m) const
{
	return !(*this == m);
}

QString File::mimeTypeIcon() const
{
    if(mimeType.name().contains("video")) {
        return "image://theme/icon-m-file-video";
    } else if(mimeType.name().contains("image")) {
        return "image://theme/icon-m-file-image";
    } else if(mimeType.name().contains("audio")) {
        return "image://theme/icon-m-file-audio";
    } else if(mimeType.name().contains("zip")) {
        return "image://theme/icon-m-file-zip";
    } else if(mimeType.name().contains("compressed")) {
        return "image://theme/icon-m-file-zip";
    } else if(mimeType.name().contains("pdf")) {
        return "image://theme/icon-m-file-pdf-dark";
    } else if(mimeType.name().contains("vcard")) {
        return "image://theme/icon-m-file-vcard";
    } else if(mimeType.name().contains("text")) {
        return "image://theme/icon-m-file-note-dark";
    } else if(mimeType.name().contains("text")) {
        return "image://theme/icon-m-file-note-dark";
    } else if(mimeType.name().contains("presentation")) {
        return "image://theme/icon-m-file-presentation-dark";
    } else if(mimeType.name().contains("spreadsheet")) {
        return "image://theme/icon-m-file-spreadsheet-dark";
    } else if(mimeType.name().contains("location")) {
        return "image://theme/icon-m-browser-location";
    } else {
        return "icon-m-file-other-dark";
    }
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

QUrl File::imageToUrl(const QImage& image) const
{
    if(image.isNull()) {
        return QUrl {};
    }
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "png");
    QString base64 = QString::fromUtf8(byteArray.toBase64());
    return QString("data:image/png;base64,") + base64;
}

QUrl File::thumbnailImageUrl() const
{
    return imageToUrl(thumbnailImage());
}
QUrl File::thumbnailSquareImageUrl() const
{
    return imageToUrl(thumbnailSquareImage());
}

#if defined(SFOS)
Enums::MessageType File::type() const
#else
MessageType File::type() const
#endif
{
	return MediaUtils::messageType(mimeType);
}

QUrl File::localFileUrl() const
{
    return localFilePath.isEmpty() ? QUrl() : QUrl::fromLocalFile(localFilePath);
}

QString File::details() const
{
	const auto formattedSize = [this]() {
		if (size) {
#if defined(SFOS)
            return QmlUtils::formattedDataSize(*size);
#else
            return QLocale::system().formattedDataSize(*size);
#endif
        }

		if (const QFileInfo fileInfo(localFilePath); fileInfo.exists()) {
#if defined(SFOS)
            return QmlUtils::formattedDataSize(*size);
#else
            return QLocale::system().formattedDataSize(fileInfo.size());
#endif
        }

		return QString();
	}();
	const auto formattedDateTime = [this]() {
		if (lastModified.isValid()) {
			return QLocale::system().toString(lastModified, QObject::tr("dd MMM at hh:mm"));
		}

		return QString();
	}();

	if (formattedSize.isEmpty() && formattedDateTime.isEmpty()) {
		return QObject::tr("No information");
	}

	if (formattedSize.isEmpty()) {
		return formattedDateTime;
	}

	if (formattedDateTime.isEmpty()) {
		return formattedSize;
	}

	return QStringLiteral("%1, %2").arg(formattedSize, formattedDateTime);
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
