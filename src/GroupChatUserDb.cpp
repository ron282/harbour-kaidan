// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "GroupChatUserDb.h"

#include <QSqlDriver>
#include <QSqlField>
#include <QSqlQuery>
#include <QSqlRecord>

#include "Database.h"
#include "Globals.h"
#include "SqlUtils.h"

using namespace SqlUtils;

static const QString COL_ACCOUNT_JID = QStringLiteral("accountJid");
static const QString COL_CHAT_JID    = QStringLiteral("chatJid");
static const QString COL_ID          = QStringLiteral("id");
static const QString COL_JID         = QStringLiteral("jid");
static const QString COL_NAME        = QStringLiteral("name");
static const QString COL_STATUS      = QStringLiteral("status");

GroupChatUserDb *GroupChatUserDb::s_instance = nullptr;

GroupChatUserDb::GroupChatUserDb(Database *database, QObject *parent)
    : DatabaseComponent(database, parent)
{
    Q_ASSERT(!GroupChatUserDb::s_instance);
    s_instance = this;
}

GroupChatUserDb::~GroupChatUserDb()
{
    s_instance = nullptr;
}

GroupChatUserDb *GroupChatUserDb::instance()
{
    return s_instance;
}

QFuture<std::optional<GroupChatUser>> GroupChatUserDb::user(const QString &accountJid, const QString &chatJid, const QString &participantId)
{
    return run([this, accountJid, chatJid, participantId]() {
        return _user(accountJid, chatJid, participantId);
    });
}

std::optional<GroupChatUser> GroupChatUserDb::_user(const QString &accountJid, const QString &chatJid, const QString &participantId)
{
    auto query = createQuery();
    query.setForwardOnly(true);

    QMap<QString, QVariant> keyValuePairs = {
        { COL_ACCOUNT_JID, accountJid },
        { COL_CHAT_JID, chatJid },
        { COL_ID, participantId }
    };

    execQuery(query,
              QStringLiteral("SELECT * FROM " DB_TABLE_GROUP_CHAT_USERS)
              + simpleWhereStatement(&sqlDriver(), keyValuePairs)
              + QStringLiteral(" LIMIT 1"));

    QList<GroupChatUser> users;
    parseUsersFromQuery(query, users);

    if (users.isEmpty())
        return std::nullopt;

    return users.constFirst();
}

QFuture<QList<GroupChatUser>> GroupChatUserDb::users(const QString &accountJid, const QString &chatJid, int offset)
{
    return run([this, accountJid, chatJid, offset]() {
        auto query = createQuery();
        query.setForwardOnly(true);

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, accountJid },
            { COL_CHAT_JID, chatJid }
        };

        execQuery(query,
                  QStringLiteral("SELECT * FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs)
                  + QStringLiteral(" ORDER BY ")
                  + COL_NAME + QStringLiteral(", ") + COL_STATUS
                  + QStringLiteral(" LIMIT %1, %2").arg(offset).arg(DB_QUERY_LIMIT_GROUP_CHAT_USERS));

        QList<GroupChatUser> result;
        parseUsersFromQuery(query, result);
        return result;
    });
}

QFuture<QList<QString>> GroupChatUserDb::userJids(const QString &accountJid, const QString &chatJid)
{
    return run([this, accountJid, chatJid]() {
        auto query = createQuery();
        query.setForwardOnly(true);

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, accountJid },
            { COL_CHAT_JID, chatJid }
        };

        execQuery(query,
                  QStringLiteral("SELECT ") + COL_JID + QStringLiteral(" FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs));

        QList<QString> jids;
        while (query.next()) {
            if (const auto jid = query.value(0).toString(); !jid.isEmpty())
                jids.append(jid);
        }
        return jids;
    });
}

QFuture<void> GroupChatUserDb::handleUserAllowedOrBanned(const GroupChatUser &user)
{
    return run([this, user]() {
        auto query = createQuery();

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, user.accountJid },
            { COL_CHAT_JID, user.chatJid },
            { COL_JID, user.jid }
        };

        execQuery(query,
                  QStringLiteral("SELECT 1 FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs)
                  + QStringLiteral(" LIMIT 1"));

        if (query.next()) {
            updateUserByJid(user.accountJid, user.chatJid, user.jid, [status = user.status](GroupChatUser &stored) {
                stored.status = status;
            });
        } else {
            addUser(user);
        }
    });
}

QFuture<void> GroupChatUserDb::handleUserDisallowedOrUnbanned(const GroupChatUser &user)
{
    return run([this, user]() {
        auto query = createQuery();

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, user.accountJid },
            { COL_CHAT_JID, user.chatJid },
            { COL_JID, user.jid },
            { COL_STATUS, static_cast<int>(user.status) }
        };

        execQuery(query,
                  QStringLiteral("SELECT 1 FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs)
                  + QStringLiteral(" LIMIT 1"));

        if (query.next())
            removeUser(user);
    });
}

QFuture<void> GroupChatUserDb::handleParticipantReceived(GroupChatUser participant)
{
    return run([this, participant]() mutable {
        auto query = createQuery();

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, participant.accountJid },
            { COL_CHAT_JID, participant.chatJid },
            { COL_ID, participant.id }
        };

        execQuery(query,
                  QStringLiteral("SELECT 1 FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs)
                  + QStringLiteral(" LIMIT 1"));

        participant.status = GroupChatUser::Status::Joined;

        if (query.next()) {
            updateUserById(participant.accountJid, participant.chatJid, participant.id, [participant](GroupChatUser &user) {
                user.name = participant.name;
                user.status = participant.status;
            });
        } else {
            QMap<QString, QVariant> jidPairs = {
                { COL_ACCOUNT_JID, participant.accountJid },
                { COL_CHAT_JID, participant.chatJid },
                { COL_JID, participant.jid }
            };
            execQuery(query,
                      QStringLiteral("SELECT 1 FROM " DB_TABLE_GROUP_CHAT_USERS)
                      + simpleWhereStatement(&sqlDriver(), jidPairs)
                      + QStringLiteral(" LIMIT 1"));

            if (query.next()) {
                updateUserByJid(participant.accountJid, participant.chatJid, participant.jid, [participant](GroupChatUser &user) {
                    user.id = participant.id;
                    user.name = participant.name;
                    user.status = participant.status;
                });
            } else {
                addUser(participant);
            }
        }
    });
}

QFuture<void> GroupChatUserDb::handleParticipantLeft(const GroupChatUser &participant)
{
    return run([this, participant]() {
        auto query = createQuery();

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, participant.accountJid },
            { COL_CHAT_JID, participant.chatJid },
            { COL_ID, participant.id }
        };

        execQuery(query,
                  QStringLiteral("SELECT ") + COL_STATUS
                  + QStringLiteral(" FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs)
                  + QStringLiteral(" LIMIT 1"));

        if (query.next()) {
            const auto status = static_cast<GroupChatUser::Status>(query.value(0).toInt());
            // Keep allowed users as "Left" so we remember they were members.
            // Other users (e.g., Joined without prior Allowed entry) are removed.
            if (status == GroupChatUser::Status::Allowed) {
                updateUserById(participant.accountJid, participant.chatJid, participant.id,
                               [](GroupChatUser &user) {
                                   user.status = GroupChatUser::Status::Left;
                               });
            } else {
                removeUser(participant);
            }
        }
    });
}

QFuture<void> GroupChatUserDb::handleMessageSender(GroupChatUser sender)
{
    return run([this, sender]() mutable {
        auto query = createQuery();

        QMap<QString, QVariant> keyValuePairs = {
            { COL_ACCOUNT_JID, sender.accountJid },
            { COL_CHAT_JID, sender.chatJid },
            { COL_ID, sender.id }
        };

        execQuery(query,
                  QStringLiteral("SELECT ") + COL_ID
                  + QStringLiteral(" FROM " DB_TABLE_GROUP_CHAT_USERS)
                  + simpleWhereStatement(&sqlDriver(), keyValuePairs)
                  + QStringLiteral(" LIMIT 1"));

        if (!query.next()) {
            sender.status = GroupChatUser::Status::Left;
            addUser(sender);
        }
    });
}

QFuture<void> GroupChatUserDb::removeUsers(const QString &accountJid)
{
    return run([this, accountJid]() {
        _removeUsers(accountJid);
    });
}

void GroupChatUserDb::_removeUsers(const QString &accountJid)
{
    auto query = createQuery();
    QMap<QString, QVariant> keyValuePairs = { { COL_ACCOUNT_JID, accountJid } };
    execQuery(query,
              QStringLiteral("DELETE FROM " DB_TABLE_GROUP_CHAT_USERS)
              + simpleWhereStatement(&sqlDriver(), keyValuePairs));
}

QFuture<void> GroupChatUserDb::removeUsers(const QString &accountJid, const QString &chatJid)
{
    return run([this, accountJid, chatJid]() {
        _removeUsers(accountJid, chatJid);
    });
}

void GroupChatUserDb::_removeUsers(const QString &accountJid, const QString &chatJid)
{
    auto query = createQuery();
    QMap<QString, QVariant> keyValuePairs = {
        { COL_ACCOUNT_JID, accountJid },
        { COL_CHAT_JID, chatJid }
    };
    execQuery(query,
              QStringLiteral("DELETE FROM " DB_TABLE_GROUP_CHAT_USERS)
              + simpleWhereStatement(&sqlDriver(), keyValuePairs));
}

void GroupChatUserDb::addUser(const GroupChatUser &user)
{
    const auto accountJid = user.accountJid;
    const auto chatJid = user.chatJid;

    auto query = createQuery();
    execQuery(query,
              QStringLiteral("INSERT OR IGNORE INTO " DB_TABLE_GROUP_CHAT_USERS
                             " (accountJid, chatJid, id, jid, name, status)"
                             " VALUES (:accountJid, :chatJid, :id, :jid, :name, :status)"),
              {
                  { u":accountJid", accountJid },
                  { u":chatJid", chatJid },
                  { u":id", user.id },
                  { u":jid", user.jid },
                  { u":name", user.name },
                  { u":status", static_cast<int>(user.status) }
              });

    Q_EMIT userAdded(user);
    Q_EMIT userJidsChanged(accountJid, chatJid);
}

void GroupChatUserDb::updateUserById(const QString &accountJid, const QString &chatJid,
                                     const QString &userId,
                                     const std::function<void(GroupChatUser &)> &updateUser)
{
    updateUserByKeyValuePairs(updateUser,
                              { { COL_ACCOUNT_JID, accountJid },
                                { COL_CHAT_JID, chatJid },
                                { COL_ID, userId } });
}

void GroupChatUserDb::updateUserByJid(const QString &accountJid, const QString &chatJid,
                                      const QString &userJid,
                                      const std::function<void(GroupChatUser &)> &updateUser)
{
    updateUserByKeyValuePairs(updateUser,
                              { { COL_ACCOUNT_JID, accountJid },
                                { COL_CHAT_JID, chatJid },
                                { COL_JID, userJid } });
}

void GroupChatUserDb::updateUserByKeyValuePairs(const std::function<void(GroupChatUser &)> &updateUser,
                                                const QMap<QString, QVariant> &keyValuePairs)
{
    auto query = createQuery();
    query.setForwardOnly(true);

    execQuery(query,
              QStringLiteral("SELECT * FROM " DB_TABLE_GROUP_CHAT_USERS)
              + simpleWhereStatement(&sqlDriver(), keyValuePairs)
              + QStringLiteral(" LIMIT 1"));

    QList<GroupChatUser> users;
    parseUsersFromQuery(query, users);

    if (!users.isEmpty()) {
        const auto oldUser = users.constFirst();
        auto newUser = oldUser;
        updateUser(newUser);

        if (oldUser != newUser) {
            QSqlRecord record = createUpdateRecord(oldUser, newUser);
            execQuery(query,
                      sqlDriver().sqlStatement(QSqlDriver::UpdateStatement,
                                               QStringLiteral(DB_TABLE_GROUP_CHAT_USERS),
                                               record, false)
                      + simpleWhereStatement(&sqlDriver(), keyValuePairs));

            userUpdated(newUser);
        }
    }
}

void GroupChatUserDb::parseUsersFromQuery(QSqlQuery &query, QList<GroupChatUser> &users)
{
    QSqlRecord rec = query.record();
    int idxAccountJid = rec.indexOf(COL_ACCOUNT_JID);
    int idxChatJid    = rec.indexOf(COL_CHAT_JID);
    int idxId         = rec.indexOf(COL_ID);
    int idxJid        = rec.indexOf(COL_JID);
    int idxName       = rec.indexOf(COL_NAME);
    int idxStatus     = rec.indexOf(COL_STATUS);

    while (query.next()) {
        GroupChatUser user;
        user.accountJid = query.value(idxAccountJid).toString();
        user.chatJid    = query.value(idxChatJid).toString();
        user.id         = query.value(idxId).toString();
        user.jid        = query.value(idxJid).toString();
        user.name       = query.value(idxName).toString();
        user.status     = static_cast<GroupChatUser::Status>(query.value(idxStatus).toInt());
        users << user;
    }
}

QSqlRecord GroupChatUserDb::createUpdateRecord(const GroupChatUser &oldUser, const GroupChatUser &newUser)
{
    QSqlRecord rec;
    if (oldUser.accountJid != newUser.accountJid)
        rec.append(createSqlField(COL_ACCOUNT_JID, newUser.accountJid));
    if (oldUser.chatJid != newUser.chatJid)
        rec.append(createSqlField(COL_CHAT_JID, newUser.chatJid));
    if (oldUser.id != newUser.id)
        rec.append(createSqlField(COL_ID, newUser.id));
    if (oldUser.jid != newUser.jid)
        rec.append(createSqlField(COL_JID, newUser.jid));
    if (oldUser.name != newUser.name)
        rec.append(createSqlField(COL_NAME, newUser.name));
    if (oldUser.status != newUser.status)
        rec.append(createSqlField(COL_STATUS, static_cast<int>(newUser.status)));
    return rec;
}

void GroupChatUserDb::removeUser(const GroupChatUser &user)
{
    auto query = createQuery();
    const auto accountJid = user.accountJid;
    const auto chatJid = user.chatJid;

    bool hasId = !user.id.isEmpty();
    QMap<QString, QVariant> keyValuePairs = {
        { COL_ACCOUNT_JID, accountJid },
        { COL_CHAT_JID, chatJid },
        { hasId ? COL_ID : COL_JID, hasId ? QVariant(user.id) : QVariant(user.jid) }
    };

    execQuery(query,
              QStringLiteral("DELETE FROM " DB_TABLE_GROUP_CHAT_USERS)
              + simpleWhereStatement(&sqlDriver(), keyValuePairs));

    Q_EMIT userRemoved(user);
    Q_EMIT userJidsChanged(accountJid, chatJid);
}

#include "moc_GroupChatUserDb.cpp"
