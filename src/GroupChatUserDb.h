// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "DatabaseComponent.h"
#include "GroupChatUser.h"

class GroupChatUserDb : public DatabaseComponent
{
    Q_OBJECT

public:
    explicit GroupChatUserDb(Database *database, QObject *parent = nullptr);
    ~GroupChatUserDb() override;

    static GroupChatUserDb *instance();

    QFuture<std::optional<GroupChatUser>> user(const QString &accountJid, const QString &chatJid, const QString &participantId);
    std::optional<GroupChatUser> _user(const QString &accountJid, const QString &chatJid, const QString &participantId);

    QFuture<QList<GroupChatUser>> users(const QString &accountJid, const QString &chatJid, int offset = 0);
    QFuture<QList<QString>> userJids(const QString &accountJid, const QString &chatJid);
    Q_SIGNAL void userJidsChanged(const QString &accountJid, const QString &chatJid);

    QFuture<void> handleUserAllowedOrBanned(const GroupChatUser &user);
    QFuture<void> handleUserDisallowedOrUnbanned(const GroupChatUser &user);
    QFuture<void> handleParticipantReceived(GroupChatUser participant);
    QFuture<void> handleParticipantLeft(const GroupChatUser &participant);
    QFuture<void> handleMessageSender(GroupChatUser sender);

    Q_SIGNAL void userAdded(const GroupChatUser &user);
    Q_SIGNAL void userUpdated(const GroupChatUser &user);
    Q_SIGNAL void userRemoved(const GroupChatUser &user);

    QFuture<void> removeUsers(const QString &accountJid);
    void _removeUsers(const QString &accountJid);
    QFuture<void> removeUsers(const QString &accountJid, const QString &chatJid);
    void _removeUsers(const QString &accountJid, const QString &chatJid);

private:
    void addUser(const GroupChatUser &user);
    void updateUserById(const QString &accountJid, const QString &chatJid, const QString &userId,
                        const std::function<void(GroupChatUser &)> &updateUser);
    void updateUserByJid(const QString &accountJid, const QString &chatJid, const QString &userJid,
                         const std::function<void(GroupChatUser &)> &updateUser);
    void updateUserByKeyValuePairs(const std::function<void(GroupChatUser &)> &updateUser,
                                   const QMap<QString, QVariant> &keyValuePairs);
    static void parseUsersFromQuery(QSqlQuery &query, QList<GroupChatUser> &users);
    static QSqlRecord createUpdateRecord(const GroupChatUser &oldUser, const GroupChatUser &newUser);
    void removeUser(const GroupChatUser &user);

    static GroupChatUserDb *s_instance;
};
