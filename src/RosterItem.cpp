// SPDX-FileCopyrightText: 2019 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2022 Bhavy Airi <airiragahv@gmail.com>
// SPDX-FileCopyrightText: 2022 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "RosterItem.h"

#include <QXmppUtils.h>

#if defined(SFOS)
bool RosterItem::operator==(const RosterItem &o) const
{
    return
        jid == o.jid &&
        name == o.name &&
        subscription == o.subscription &&
        encryption == o.encryption &&
        unreadMessages == o.unreadMessages &&
        lastMessageDateTime == o.lastMessageDateTime &&
        lastMessage == o.lastMessage &&
        lastReadOwnMessageId == o.lastReadOwnMessageId &&
        lastReadContactMessageId == o.lastReadContactMessageId &&
        draftMessageId == o.draftMessageId &&
        readMarkerPending == o.readMarkerPending &&
        pinningPosition == o.pinningPosition &&
        chatStateSendingEnabled == o.chatStateSendingEnabled &&
        readMarkerSendingEnabled == o.readMarkerSendingEnabled &&
        groups == o.groups &&
        automaticMediaDownloadsRule == o.automaticMediaDownloadsRule;
}



bool RosterItem::operator!=(const RosterItem &o) const
{
    return !(*this == o);
}
#endif

RosterItem::RosterItem(const QString &accountJid, const QXmppRosterIq::Item &item, const QDateTime &lastMessageDateTime)
	: accountJid(accountJid), jid(item.bareJid()), name(item.name()), subscription(item.subscriptionType()), lastMessageDateTime(lastMessageDateTime)
{
	const auto rosterGroups = item.groups();
#if defined(SFOS)
    groups = rosterGroups.toList();
#else
    groups = QVector(rosterGroups.cbegin(), rosterGroups.cend());
#endif
}

QString RosterItem::displayName() const
{
    return name.isEmpty() ? QXmppUtils::jidToUser(jid) : name;
}

bool RosterItem::isSendingPresence() const
{
    return subscription == QXmppRosterIq::Item::To || subscription == QXmppRosterIq::Item::Both;
}

bool RosterItem::isReceivingPresence() const
{
    return subscription == QXmppRosterIq::Item::From || subscription == QXmppRosterIq::Item::Both;
}

bool RosterItem::operator<(const RosterItem &other) const
{
	if (pinningPosition == -1 && other.pinningPosition == -1) {
		if (lastMessageDateTime != other.lastMessageDateTime) {
			return lastMessageDateTime > other.lastMessageDateTime;
		}
		return displayName().toUpper() < other.displayName().toUpper();
	}
	return pinningPosition > other.pinningPosition;
}

bool RosterItem::operator>(const RosterItem &other) const
{
	if (pinningPosition == -1 && other.pinningPosition == -1) {
		if (lastMessageDateTime != other.lastMessageDateTime) {
			return lastMessageDateTime < other.lastMessageDateTime;
		}
		return displayName().toUpper() > other.displayName().toUpper();
	}
	return pinningPosition < other.pinningPosition;
}

bool RosterItem::operator<=(const RosterItem &other) const
{
	if (pinningPosition == -1 && other.pinningPosition == -1) {
		if (lastMessageDateTime != other.lastMessageDateTime) {
			return lastMessageDateTime >= other.lastMessageDateTime;
		}
		return displayName().toUpper() <= other.displayName().toUpper();
	}
	return pinningPosition >= other.pinningPosition;
}

bool RosterItem::operator>=(const RosterItem &other) const
{
	if (pinningPosition == -1 && other.pinningPosition == -1) {
		if (lastMessageDateTime != other.lastMessageDateTime) {
			return lastMessageDateTime <= other.lastMessageDateTime;
		}
		return displayName().toUpper() >= other.displayName().toUpper();
	}
	return pinningPosition <= other.pinningPosition;
}
