// SPDX-FileCopyrightText: 2019 Filipe Azevedo <pasnox@gmail.com>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "CameraImageCapture.h"

CameraImageCapture::CameraImageCapture(QMediaObject *mediaObject, QObject *parent)
	: QCameraImageCapture(mediaObject, parent)
{
	connect(this, &QCameraImageCapture::imageSaved,
		this, [this](int id, const QString &filePath) {
			Q_UNUSED(id);
			m_actualLocation = QUrl::fromLocalFile(filePath);
			Q_EMIT actualLocationChanged(m_actualLocation);
		});
}

QUrl CameraImageCapture::actualLocation() const
{
	return m_actualLocation;
}

bool CameraImageCapture::setMediaObject(QMediaObject *mediaObject)
{
	const QMultimedia::AvailabilityStatus previousAvailability = availability();
	const bool result = QCameraImageCapture::setMediaObject(mediaObject);

	if (previousAvailability != availability()) {
#if defined(SFOS)
        QMetaObject::invokeMethod(this, "availabilityChanged", 
            Qt::QueuedConnection,
            Q_ARG(QMultimedia::AvailabilityStatus, availability()));
#else
		QMetaObject::invokeMethod(this, [this]() {
				Q_EMIT availabilityChanged(availability());
			}, Qt::QueuedConnection);
#endif
	}

	return result;
}
