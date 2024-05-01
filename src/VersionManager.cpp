// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "VersionManager.h"

#include <QStringBuilder>

#include <QXmppClient.h>
#include <QXmppVersionManager.h>
#include <QXmppRosterManager.h>
#include <QXmppPresence.h>

VersionManager::VersionManager(QXmppClient *client, QObject *parent)
	: QObject(parent),
	  m_manager(client->findExtension<QXmppVersionManager>()),
	  m_client(client)
{
	Q_ASSERT(m_manager);

	// publish kaidan version
	m_manager->setClientName(QStringLiteral(APPLICATION_DISPLAY_NAME));
	m_manager->setClientVersion(QStringLiteral(VERSION_STRING));
	m_manager->setClientOs(QSysInfo::prettyProductName());

	connect(m_manager, &QXmppVersionManager::versionReceived,
		this, &VersionManager::clientVersionReceived);
}

void VersionManager::fetchVersions(const QString &bareJid, const QString &resource)
{
	const auto fetchVersion = [this, &bareJid](const QString &res) {
#if defined(SFOS)
		m_manager->requestVersion(bareJid % '/' % res);
#else
        m_manager->requestVersion(bareJid % u'/' % res);
#endif
	};

	if (resource.isEmpty()) {
		const auto resources = m_client->findExtension<QXmppRosterManager>()->getResources(bareJid);
		std::for_each(resources.cbegin(), resources.cend(), fetchVersion);
	} else {
		fetchVersion(resource);
	}
}
