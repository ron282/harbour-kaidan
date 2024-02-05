// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "OmemoWatcher.h"

#include "OmemoCache.h"

#if defined(SFOS)
#include <QDebug>
#endif

QString OmemoWatcher::jid() const
{
	return m_jid;
}

void OmemoWatcher::setJid(const QString &jid)
{
	m_jid = jid;

	connect(OmemoCache::instance(), &OmemoCache::distrustedDevicesUpdated, this, &OmemoWatcher::handleDistrustedDevicesUpdated);
	connect(OmemoCache::instance(), &OmemoCache::usableDevicesUpdated, this, &OmemoWatcher::handleUsableDevicesUpdated);
	connect(OmemoCache::instance(), &OmemoCache::authenticatableDevicesUpdated, this, &OmemoWatcher::handleAuthenticatableDevicesUpdated);

	m_distrustedDevices = OmemoCache::instance()->distrustedDevices(jid);
	m_usableDevices = OmemoCache::instance()->usableDevices(jid);
	m_authenticatableDevices = OmemoCache::instance()->authenticatableDevices(jid);

	Q_EMIT jidChanged();
	Q_EMIT distrustedDevicesChanged();
	Q_EMIT usableDevicesChanged();
	Q_EMIT authenticatableDevicesChanged();
}

#if defined (SFOS)
QList<QString> OmemoWatcher::distrustedDevices() const
{
    QList<QString> ls;
    for (const auto &d : m_distrustedDevices)
        ls.append(d.label);
    return ls;
}
#else
QList<OmemoManager::Device> OmemoWatcher::distrustedDevices() const
{
	return m_distrustedDevices;
}
#endif

#if defined (SFOS)
QList<QString> OmemoWatcher::usableDevices() const
{
    QList<QString> ls;
    for (const auto &d : m_usableDevices)
        ls.append(d.label);
    return ls;
}
#else
QList<OmemoManager::Device> OmemoWatcher::usableDevices() const
{
	return m_usableDevices;
}
#endif

#if defined (SFOS)
QList<QString> OmemoWatcher::authenticatableDevices() const
{
    QList<QString> ls;
    for (const auto &d : m_authenticatableDevices)
        ls.append(d.label);
    return ls;
}
#else
QList<OmemoManager::Device> OmemoWatcher::authenticatableDevices() const
{
	return m_authenticatableDevices;
}
#endif

void OmemoWatcher::handleDistrustedDevicesUpdated(const QString &jid, const QList<OmemoManager::Device> &distrustedDevices)
{
	if (jid == m_jid) {
		m_distrustedDevices = distrustedDevices;
		Q_EMIT distrustedDevicesChanged();
	}
}

void OmemoWatcher::handleUsableDevicesUpdated(const QString &jid, const QList<OmemoManager::Device> &usableDevices)
{
	if (jid == m_jid) {
		m_usableDevices = usableDevices;
		Q_EMIT usableDevicesChanged();
	}
}

void OmemoWatcher::handleAuthenticatableDevicesUpdated(const QString &jid, const QList<OmemoManager::Device> &authenticatableDevices)
{
	if (jid == m_jid) {
		m_authenticatableDevices = authenticatableDevices;
		Q_EMIT authenticatableDevicesChanged();
	}
}
