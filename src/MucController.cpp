// SPDX-FileCopyrightText: 2024 Kaidan Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "MucController.h"

#include <QXmppMucManager.h>
#include <QXmppStanza.h>
#include <QXmppUtils.h>

#include "AccountManager.h"
#include "GroupChatController.h"
#include "Kaidan.h"
#include "RosterItem.h"
#include "RosterModel.h"

MucController::MucController(GroupChatController *groupChatController,
                             QXmppMucManager *mucManager,
                             QObject *parent)
    : QObject(parent)
    , m_groupChatController(groupChatController)
    , m_manager(mucManager)
{
}

void MucController::joinRoom(const QString &roomJid, const QString &nickname)
{
    const bool isNewRoom = !m_rooms.contains(roomJid);
    auto *room = getOrAddRoom(roomJid);

    const auto nick = nickname.isEmpty()
        ? QXmppUtils::jidToUser(AccountManager::instance()->jid())
        : nickname;
    room->setNickName(nick);

    // Only connect signals once per room object to avoid duplicate emissions
    if (isNewRoom) {
        connect(room, &QXmppMucRoom::joined, this, [this, room, roomJid]() {
            // MUC rooms are not part of the XMPP roster, so we add them to the roster
            // model manually to make them appear in the conversation list.
            const auto accountJid = AccountManager::instance()->jid();
            if (!RosterModel::instance()->hasItem(accountJid, roomJid)) {
                RosterItem item;
                item.accountJid = accountJid;
                item.jid = roomJid;
                item.groupChatParticipantId = QStringLiteral("muc");
                item.groupChatName = room->name();
                item.lastMessageDateTime = QDateTime::currentDateTimeUtc();
                item.automaticMediaDownloadsRule = RosterItem::AutomaticMediaDownloadsRule::Default;
                Q_EMIT RosterModel::instance()->addItemRequested(item);
            }
            Q_EMIT m_groupChatController->groupChatJoined(roomJid);
        });

        // Room name arrives asynchronously via disco#info — update both model and DB.
        connect(room, &QXmppMucRoom::nameChanged, this, [roomJid](const QString &roomName) {
            const auto accountJid = AccountManager::instance()->jid();
            Q_EMIT RosterModel::instance()->updateItemRequested(accountJid, roomJid, [roomName](RosterItem &item) {
                item.groupChatName = roomName;
            });
        });

        connect(room, &QXmppMucRoom::error, this, [this, roomJid](const QXmppStanza::Error &error) {
            Q_EMIT m_groupChatController->groupChatJoiningFailed(roomJid, error.text());
        });
    }

    room->join();
}

void MucController::leaveRoom(const QString &roomJid)
{
    auto *room = m_rooms.value(roomJid);
    if (!room) {
        Q_EMIT m_groupChatController->groupChatLeavingFailed(roomJid, tr("Not in this room"));
        return;
    }

    connect(room, &QXmppMucRoom::left, this, [this, roomJid]() {
        m_rooms.remove(roomJid);
        Q_EMIT m_groupChatController->groupChatLeft(roomJid);
    });

    room->leave();
}

void MucController::sendMessage(const QString &roomJid, const QString &text)
{
    auto *room = m_rooms.value(roomJid);
    if (room && room->isJoined()) {
        room->sendMessage(text);
    } else {
        qWarning() << "[MucController] sendMessage: not joined to" << roomJid;
    }
}

bool MucController::isJoined(const QString &roomJid) const
{
    auto *room = m_rooms.value(roomJid);
    return room && room->isJoined();
}

QXmppMucRoom *MucController::getOrAddRoom(const QString &roomJid)
{
    if (auto *existing = m_rooms.value(roomJid))
        return existing;

    auto *room = m_manager->addRoom(roomJid);
    m_rooms[roomJid] = room;
    return room;
}

#include "moc_MucController.cpp"
