// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QObject>

struct GroupChatUser;
class MixController;
class QXmppMixManager;

class GroupChatController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit GroupChatController(QXmppMixManager *mixManager, QObject *parent = nullptr);

    bool busy() const;
    Q_SIGNAL void busyChanged();

    Q_INVOKABLE void joinGroupChat(const QString &groupChatJid, const QString &nickname);
    Q_SIGNAL void groupChatJoined(const QString &groupChatJid);
    Q_SIGNAL void groupChatJoiningFailed(const QString &groupChatJid, const QString &errorMessage);

    Q_INVOKABLE void leaveGroupChat(const QString &groupChatJid);
    Q_SIGNAL void groupChatLeft(const QString &groupChatJid);
    Q_SIGNAL void groupChatLeavingFailed(const QString &groupChatJid, const QString &errorMessage);

    Q_INVOKABLE void requestGroupChatUsers(const QString &groupChatJid);

    Q_SIGNAL void groupChatMadePrivate(const QString &groupChatJid);
    Q_SIGNAL void groupChatMadePublic(const QString &groupChatJid);
    Q_SIGNAL void groupChatDeleted(const QString &groupChatJid);

    Q_SIGNAL void participantReceived(const GroupChatUser &participant);
    Q_SIGNAL void participantLeft(const GroupChatUser &participant);
    Q_SIGNAL void userAllowedOrBanned(const GroupChatUser &user);
    Q_SIGNAL void userDisallowedOrUnbanned(const GroupChatUser &user);

private:
    void setBusy(bool busy);

    MixController *const m_mixController;
    bool m_busy = false;
};
