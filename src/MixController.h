// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QObject>
#include <QXmppClient.h>
#include <QXmppMixManager.h>
#include <QXmppMixParticipantItem.h>
#include <QXmppStanza.h>

class GroupChatController;
class QXmppMixInfoItem;

class MixController : public QObject
{
    Q_OBJECT

public:
    explicit MixController(GroupChatController *groupChatController,
                           QXmppClient *client,
                           QXmppMixManager *mixManager,
                           QObject *parent = nullptr);

    void joinChannel(const QString &channelJid, const QString &nickname);
    void leaveChannel(const QString &channelJid);
    void sendMessage(const QString &channelJid, const QString &text);
    void requestChannelUsers(const QString &channelJid);
    void requestChannelInformation(const QString &channelJid);

private:
    void handleParticipantReceived(const QString &channelJid, const QXmppMixParticipantItem &participantItem);
    void handleParticipantLeft(const QString &channelJid, const QString &participantId);
    void handleChannelDeleted(const QString &channelJid);
    void handleChannelInformationUpdated(const QString &channelJid, const QXmppMixInfoItem &information);
    void handleJidAllowed(const QString &channelJid, const QString &jid);
    void handleJidDisallowed(const QString &channelJid, const QString &jid);
    void handleJidBanned(const QString &channelJid, const QString &jid);
    void handleJidUnbanned(const QString &channelJid, const QString &jid);

    GroupChatController *const m_groupChatController;
    QXmppClient *const m_client;
    QXmppMixManager *const m_manager;
};
