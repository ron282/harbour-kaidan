// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "GroupChatController.h"

#include "AccountManager.h"
#include "ClientWorker.h"
#include "FutureUtils.h"
#include "GroupChatUser.h"
#include "GroupChatUserDb.h"
#include "Kaidan.h"
#include "MixController.h"
#include "MucController.h"
#include "RosterDb.h"
#include "RosterItem.h"

GroupChatController::GroupChatController(QObject *parent)
    : QObject(parent)
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
    runOnThread(Kaidan::instance()->client(), [groupChatJid, nickname]() {
        auto *worker = Kaidan::instance()->client();
        if (worker->isMixSupported()) {
            worker->mixController()->joinChannel(groupChatJid, nickname);
        } else {
            worker->mucController()->joinRoom(groupChatJid, nickname);
        }
    });
}

void GroupChatController::leaveGroupChat(const QString &groupChatJid)
{
    setBusy(true);
    runOnThread(Kaidan::instance()->client(), [groupChatJid]() {
        auto *worker = Kaidan::instance()->client();
        if (worker->mucController()->isJoined(groupChatJid)) {
            worker->mucController()->leaveRoom(groupChatJid);
        } else {
            worker->mixController()->leaveChannel(groupChatJid);
        }
    });
}

void GroupChatController::requestGroupChatUsers(const QString &groupChatJid)
{
    runOnThread(Kaidan::instance()->client(), [groupChatJid]() {
        auto *worker = Kaidan::instance()->client();
        if (worker->mucController()->isJoined(groupChatJid)) {
            // MUC participant list not yet implemented
        } else {
            worker->mixController()->requestChannelUsers(groupChatJid);
        }
    });
}

void GroupChatController::sendGroupChatMessage(const QString &groupChatJid, const QString &text)
{
    runOnThread(Kaidan::instance()->client(), [groupChatJid, text]() {
        auto *worker = Kaidan::instance()->client();
        if (worker->mucController()->isJoined(groupChatJid)) {
            worker->mucController()->sendMessage(groupChatJid, text);
        } else {
            // MIX channel: send as a regular groupchat message
            worker->mixController()->sendMessage(groupChatJid, text);
        }
    });
}

void GroupChatController::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        Q_EMIT busyChanged();
    }
}

#include "moc_GroupChatController.cpp"
