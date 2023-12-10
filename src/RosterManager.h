// SPDX-FileCopyrightText: 2017 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2020 Mathis Brüchert <mbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

// Qt
#include <QMap>
#include <QObject>
// QXmpp
class QXmppClient;
class QXmppPresence;
class QXmppRosterManager;
// Kaidan
class AvatarFileStorage;
class ClientWorker;
class VCardManager;

class RosterManager : public QObject
{
	Q_OBJECT

public:
	RosterManager(ClientWorker *clientWorker, QXmppClient *client, QObject *parent = nullptr);

	void addContact(const QString &jid, const QString &name = {}, const QString &msg = {});
	void removeContact(const QString &jid);
	void renameContact(const QString &jid, const QString &newContactName);

	void subscribeToPresence(const QString &contactJid);
	void acceptSubscriptionToPresence(const QString &contactJid);
	void refuseSubscriptionToPresence(const QString &contactJid);
	QMap<QString, QString> unrespondedPresenceSubscriptionRequests();

	void updateGroups(const QString &jid, const QString &name, const QVector<QString> &groups = {});
	Q_SIGNAL void updateGroupsRequested(const QString &jid, const QString &name, const QVector<QString> &groups);

signals:
	/**
	 * Add a contact to your roster
	 *
	 * @param nick A simple nick name for the new contact, which should be
	 *             used to display in the roster.
	 * @param msg message presented to the added contact
	 */
	void addContactRequested(const QString &jid, const QString &nick = {}, const QString &msg = {});

	/**
	 * Remove a contact from your roster
	 *
	 * Only the JID is needed.
	 */
	void removeContactRequested(const QString &jid);

	/**
	 * Change a contact's name
	 */
	void renameContactRequested(const QString &jid, const QString &newContactName);

	void subscribeToPresenceRequested(const QString &contactJid);
	void acceptSubscriptionToPresenceRequested(const QString &contactJid);
	void refuseSubscriptionToPresenceRequested(const QString &contactJid);

private:
	void populateRoster();
	void handleSubscriptionRequest(const QString &subscriberJid, const QXmppPresence &presence);
	void processSubscriptionRequestFromStranger(const QString &subscriberJid, const QString &requestText);
	void addUnrespondedSubscriptionRequest(const QString &subscriberJid, const QString &requestText);

	ClientWorker *m_clientWorker;
	QXmppClient *m_client;
	AvatarFileStorage *m_avatarStorage;
	VCardManager *m_vCardManager;
	QXmppRosterManager *m_manager;
	QMap<QString, QString> m_unprocessedSubscriptionRequests;
	QMap<QString, QString> m_pendingSubscriptionRequests;
	QMap<QString, QString> m_unrespondedSubscriptionRequests;
	bool m_isItemBeingChanged = false;
};
