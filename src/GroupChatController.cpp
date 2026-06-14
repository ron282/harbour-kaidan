// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "GroupChatController.h"

#include "AccountManager.h"
#include "GroupChatUser.h"
#include "GroupChatUserDb.h"
#include "MixController.h"
#include "RosterDb.h"
#include "RosterItem.h"

GroupChatController::GroupChatController(QXmppMixManager *mixManager, QObject *parent)
    : QObject(parent)
    , m_mixController(new MixController(this, mixManager, this))
{
    connect(this, &GroupChatController::userAllowedOrBanned,
            GroupChatUserDb::instance(), &GroupChatUserDb::handleUserAllowedOrBanned);
    connect(this, &GroupChatController::userDisallowedOrUnbanned,
            GroupChatUserDb::instance(), &GroupChatUserDb::handleUserDisallowedOrUnbanned);

    connect(this, &GroupChatController::participantReceived,
            GroupChatUserDb::instance(), &GroupChatUserDb::handleParticipantReceived);
    connect(this, &GroupChatController::participantLeft,
            GroupChatUserDb::instance(), &GroupChatUserDb::handleParticipantLeft);

    connect(this, &GroupChatController::groupChatLeft, this, [](const QString &chatJid) {
        GroupChatUserDb::instance()->removeUsers(AccountManager::instance()->jid(), chatJid);
    });

    auto setIdle = [this]() { setBusy(false); };
    connect(this, &GroupChatController::groupChatJoined,    this, setIdle);
    connect(this, &GroupChatController::groupChatJoiningFailed, this, setIdle);
    connect(this, &GroupChatController::groupChatLeft,      this, setIdle);
    connect(this, &GroupChatController::groupChatLeavingFailed, this, setIdle);
}

bool GroupChatController::busy() const
{
    return m_busy;
}

void GroupChatController::joinGroupChat(const QString &groupChatJid, const QString &nickname)
{
    setBusy(true);
    m_mixController->joinChannel(groupChatJid, nickname);
}

void GroupChatController::leaveGroupChat(const QString &groupChatJid)
{
    setBusy(true);
    m_mixController->leaveChannel(groupChatJid);
}

void GroupChatController::requestGroupChatUsers(const QString &groupChatJid)
{
    m_mixController->requestChannelUsers(groupChatJid);
}

void GroupChatController::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        Q_EMIT busyChanged();
    }
}

#include "moc_GroupChatController.cpp"
