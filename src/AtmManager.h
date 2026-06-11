// SPDX-FileCopyrightText: 2022 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

// std
#include <memory>
// Qt
#include <QObject>

class Database;
class QXmppClient;
class QXmppAtmManager;
class QXmppUri;
class TrustDb;

class AtmManager : public QObject
{
	Q_OBJECT

public:
	AtmManager(QXmppClient *client, Database *database, QObject *parent = nullptr);
	~AtmManager();


	/**
	 * Sets the JID of the current account used to store the corresponding data
	 * for a specific account.
	 *
	 * @param accountJid bare JID of the current account
	 */
	void setAccountJid(const QString &accountJid);

	/**
	 * Authenticates or distrusts end-to-end encryption keys by a given XMPP URI
	 * (e.g., from a scanned QR code).
	 *
	 * @param uri Trust Message URI
	 */
	void makeTrustDecisionsByUri(const QXmppUri &uri);
	void makeTrustDecisions(const QString &jid, const QList<QByteArray> &keyIdsForAuthentication, const QList<QByteArray> &keyIdsForDistrusting);

	/**
	 * Authenticates OMEMO keys from a Conversations-format QR code URI
	 * (xmpp:jid?roster;omemo-sid-XXX=fingerprint).
	 *
	 * Only fingerprints already known in the trust DB are processed to avoid
	 * triggering TOAKAFA distrust on unknown keys.
	 */
	void makeTrustDecisionsForConversationsFingerprints(const QString &jid, const QList<QByteArray> &fingerprints);
	Q_SIGNAL void makeTrustDecisionsRequested(const QString &jid, const QList<QString> &keyIdsForAuthentication, const QList<QString> &keyIdsForDistrusting);

private:
	QList<QByteArray> keyIdsFromHex(const QList<QString> &keyIds);

	std::unique_ptr<TrustDb> m_trustStorage;
	QXmppAtmManager *const m_manager;
};
