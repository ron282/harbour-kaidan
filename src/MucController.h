// SPDX-FileCopyrightText: 2024 Kaidan Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QMap>
#include <QObject>

class GroupChatController;
class QXmppMucManager;
class QXmppMucRoom;

class MucController : public QObject
{
    Q_OBJECT

public:
    explicit MucController(GroupChatController *groupChatController,
                           QXmppMucManager *mucManager,
                           QObject *parent = nullptr);

    void joinRoom(const QString &roomJid, const QString &nickname);
    void leaveRoom(const QString &roomJid);
    void sendMessage(const QString &roomJid, const QString &text);

    bool isJoined(const QString &roomJid) const;

private:
    QXmppMucRoom *getOrAddRoom(const QString &roomJid);

    GroupChatController *const m_groupChatController;
    QXmppMucManager *const m_manager;
    QMap<QString, QXmppMucRoom *> m_rooms;
};
