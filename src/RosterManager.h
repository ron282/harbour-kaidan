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

#pragma once

// Qt
#include <QObject>
#if defined(SFOS)
#include <QStringList>
#endif
// QXmpp
class QXmppClient;
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

#if defined(SFOS)
    void updateGroups(const QString &jid, const QString &name, const QStringList &groups = {});
    Q_SIGNAL void updateGroupsRequested(const QString &jid, const QString &name, const QStringList &groups);
#else
    void updateGroups(const QString &jid, const QString &name, const QVector<QString> &groups = {});
    Q_SIGNAL void updateGroupsRequested(const QString &jid, const QString &name, const QVector<QString> &groups);
#endif

signals:
	/**
	 * Requests to send subscription request answer (whether it was accepted
	 * or declined by the user)
	 */
	void answerSubscriptionRequestRequested(const QString &jid, bool accepted);

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

	ClientWorker *m_clientWorker;
	QXmppClient *m_client;
	AvatarFileStorage *m_avatarStorage;
	VCardManager *m_vCardManager;
	QXmppRosterManager *m_manager;
    bool m_isItemBeingChanged = false;
};
