// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

// Qt
#include <QObject>
// Kaidan
#include "OmemoManager.h"

class OmemoWatcher : public QObject
{
	Q_OBJECT

	Q_PROPERTY(QString jid READ jid WRITE setJid NOTIFY jidChanged)

#if defined(SFOS)
    Q_PROPERTY(QList<QString> distrustedDevices READ distrustedDevices NOTIFY distrustedDevicesChanged)
    Q_PROPERTY(QList<QString> usableDevices READ usableDevices NOTIFY usableDevicesChanged)
    Q_PROPERTY(QList<QString> authenticatableDevices READ authenticatableDevices NOTIFY authenticatableDevicesChanged)
#else
    Q_PROPERTY(QList<OmemoManager::Device> distrustedDevices READ distrustedDevices NOTIFY distrustedDevicesChanged)
    Q_PROPERTY(QList<OmemoManager::Device> usableDevices READ usableDevices NOTIFY usableDevicesChanged)
    Q_PROPERTY(QList<OmemoManager::Device> authenticatableDevices READ authenticatableDevices NOTIFY authenticatableDevicesChanged)
#endif

public:
	OmemoWatcher() = default;

	QString jid() const;
	void setJid(const QString &jid);
	Q_SIGNAL void jidChanged();

#if defined(SFOS)
    QList<QString> distrustedDevices() const;
#else
    QList<OmemoManager::Device> distrustedDevices() const;
#endif
    Q_SIGNAL void distrustedDevicesChanged();

#if defined(SFOS)
    QList<QString> usableDevices() const;
#else
    QList<OmemoManager::Device> usableDevices() const;
#endif
    Q_SIGNAL void usableDevicesChanged();

#if defined(SFOS)
    QList<QString> authenticatableDevices() const;
#else
    QList<OmemoManager::Device> authenticatableDevices() const;
#endif
    Q_SIGNAL void authenticatableDevicesChanged();

private:
	void handleDistrustedDevicesUpdated(const QString &jid, const QList<OmemoManager::Device> &distrustedDevices);
	void handleUsableDevicesUpdated(const QString &jid, const QList<OmemoManager::Device> &usableDevices);
	void handleAuthenticatableDevicesUpdated(const QString &jid, const QList<OmemoManager::Device> &authenticatableDevices);

	QString m_jid;

	QList<OmemoManager::Device> m_distrustedDevices;
	QList<OmemoManager::Device> m_usableDevices;
	QList<OmemoManager::Device> m_authenticatableDevices;
};

