// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "GroupChatUser.h"

#include <QXmppUtils.h>

QString GroupChatUser::displayName() const
{
    if (!name.isEmpty())
        return name;
    if (!jid.isEmpty())
        return QXmppUtils::jidToUser(jid);
    return id;
}

bool GroupChatUser::operator==(const GroupChatUser &other) const
{
    return accountJid == other.accountJid &&
           chatJid == other.chatJid &&
           id == other.id &&
           jid == other.jid &&
           name == other.name &&
           status == other.status;
}

bool GroupChatUser::operator!=(const GroupChatUser &other) const
{
    return !(*this == other);
}

bool GroupChatUser::operator<(const GroupChatUser &other) const
{
    return displayName() < other.displayName();
}
