// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "MixController.h"

#include <QXmppMixInfoItem.h>
#include <QXmppTask.h>
#include <QXmppUtils.h>

#include "AccountManager.h"
#include "GroupChatController.h"
#include "GroupChatUser.h"
#include "Kaidan.h"
#include "RosterDb.h"
#include "RosterItem.h"

MixController::MixController(GroupChatController *groupChatController,
                             QXmppMixManager *mixManager,
                             QObject *parent)
    : QObject(parent)
    , m_groupChatController(groupChatController)
    , m_manager(mixManager)
{
    connect(m_manager, &QXmppMixManager::channelInformationUpdated,
            this, &MixController::handleChannelInformationUpdated);

    connect(m_manager, &QXmppMixManager::jidAllowed,
            this, &MixController::handleJidAllowed);
    connect(m_manager, &QXmppMixManager::jidDisallowed,
            this, &MixController::handleJidDisallowed);
    connect(m_manager, &QXmppMixManager::jidBanned,
            this, &MixController::handleJidBanned);
    connect(m_manager, &QXmppMixManager::jidUnbanned,
            this, &MixController::handleJidUnbanned);

    connect(m_manager, &QXmppMixManager::participantReceived,
            this, &MixController::handleParticipantReceived);
    connect(m_manager, &QXmppMixManager::participantLeft,
            this, &MixController::handleParticipantLeft);

    connect(m_manager, &QXmppMixManager::channelDeleted,
            this, &MixController::handleChannelDeleted);
}

void MixController::joinChannel(const QString &channelJid, const QString &nickname)
{
    m_manager->joinChannel(channelJid, nickname).then(this, [this, channelJid](QXmppMixManager::JoiningResult &&result) {
        if (const auto error = std::get_if<QXmppError>(&result)) {
            QString errorMessage;
            if (error->isStanzaError()) {
                const auto stanzaError = error->value<QXmppStanza::Error>();
                switch (stanzaError->type()) {
                case QXmppStanza::Error::Cancel:
                    switch (stanzaError->condition()) {
                    case QXmppStanza::Error::ItemNotFound:
                        errorMessage = tr("The group does not exist");
                        break;
                    case QXmppStanza::Error::NotAllowed:
                        errorMessage = tr("You aren't allowed to join the group");
                        break;
                    default:
                        break;
                    }
                    break;
                default:
                    errorMessage = stanzaError->text();
                }
            } else {
                errorMessage = error->description;
            }
            Q_EMIT m_groupChatController->groupChatJoiningFailed(channelJid, errorMessage);
        } else {
            Q_EMIT m_groupChatController->groupChatJoined(channelJid);
        }
    });
}

void MixController::leaveChannel(const QString &channelJid)
{
    m_manager->leaveChannel(channelJid).then(this, [this, channelJid](QXmppClient::EmptyResult &&result) {
        if (const auto error = std::get_if<QXmppError>(&result)) {
            Q_EMIT m_groupChatController->groupChatLeavingFailed(channelJid, error->description);
        } else {
            Q_EMIT m_groupChatController->groupChatLeft(channelJid);
        }
    });
}

void MixController::requestChannelUsers(const QString &channelJid)
{
    m_manager->requestParticipants(channelJid).then(this, [this, channelJid](QXmppMixManager::ParticipantResult result) {
        if (const auto error = std::get_if<QXmppError>(&result)) {
            Q_EMIT Kaidan::instance()->passiveNotificationRequested(
                tr("Participants of %1 could not be retrieved: %2").arg(channelJid, error->description));
        } else {
            const auto participants = std::get<QVector<QXmppMixParticipantItem>>(result);
            for (const auto &participant : participants)
                handleParticipantReceived(channelJid, participant);
        }
    });
}

void MixController::requestChannelInformation(const QString &channelJid)
{
    m_manager->requestChannelInformation(channelJid).then(this, [this, channelJid](QXmppMixManager::InformationResult &&result) {
        if (const auto error = std::get_if<QXmppError>(&result)) {
            Q_EMIT Kaidan::instance()->passiveNotificationRequested(
                tr("Could not retrieve information of group %1: %2").arg(channelJid, error->description));
        } else {
            handleChannelInformationUpdated(channelJid, std::get<QXmppMixInfoItem>(result));
        }
    });
}

void MixController::handleParticipantReceived(const QString &channelJid, const QXmppMixParticipantItem &participantItem)
{
    GroupChatUser user;
    user.accountJid = AccountManager::instance()->jid();
    user.chatJid    = channelJid;
    user.id         = participantItem.id();
    user.jid        = participantItem.jid();
    user.name       = participantItem.nick();

    Q_EMIT m_groupChatController->participantReceived(user);
}

void MixController::handleParticipantLeft(const QString &channelJid, const QString &participantId)
{
    GroupChatUser user;
    user.accountJid = AccountManager::instance()->jid();
    user.chatJid    = channelJid;
    user.id         = participantId;

    Q_EMIT m_groupChatController->participantLeft(user);
}

void MixController::handleChannelDeleted(const QString &channelJid)
{
    Q_EMIT m_groupChatController->groupChatDeleted(channelJid);
}

void MixController::handleChannelInformationUpdated(const QString &channelJid, const QXmppMixInfoItem &information)
{
    RosterDb::instance()->updateItem(AccountManager::instance()->jid(), channelJid, [information](RosterItem &item) {
        item.groupChatName = information.name();
        item.groupChatDescription = information.description();
    });
}

void MixController::handleJidAllowed(const QString &channelJid, const QString &jid)
{
    GroupChatUser user;
    user.accountJid = AccountManager::instance()->jid();
    user.chatJid    = channelJid;
    user.jid        = jid;
    user.status     = GroupChatUser::Status::Allowed;
    Q_EMIT m_groupChatController->userAllowedOrBanned(user);
}

void MixController::handleJidDisallowed(const QString &channelJid, const QString &jid)
{
    GroupChatUser user;
    user.accountJid = AccountManager::instance()->jid();
    user.chatJid    = channelJid;
    user.jid        = jid;
    user.status     = GroupChatUser::Status::Allowed;
    Q_EMIT m_groupChatController->userDisallowedOrUnbanned(user);
}

void MixController::handleJidBanned(const QString &channelJid, const QString &jid)
{
    GroupChatUser user;
    user.accountJid = AccountManager::instance()->jid();
    user.chatJid    = channelJid;
    user.jid        = jid;
    user.status     = GroupChatUser::Status::Banned;
    Q_EMIT m_groupChatController->userAllowedOrBanned(user);
}

void MixController::handleJidUnbanned(const QString &channelJid, const QString &jid)
{
    GroupChatUser user;
    user.accountJid = AccountManager::instance()->jid();
    user.chatJid    = channelJid;
    user.jid        = jid;
    user.status     = GroupChatUser::Status::Banned;
    Q_EMIT m_groupChatController->userDisallowedOrUnbanned(user);
}

#include "moc_MixController.cpp"
