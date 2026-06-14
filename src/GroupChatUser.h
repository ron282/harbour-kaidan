// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QObject>
#include <QString>

struct GroupChatUser {
    Q_GADGET

public:
    enum class Status {
        Allowed,
        Joined,
        Left,
        Banned,
    };
    Q_ENUM(Status)

    QString displayName() const;

    bool operator==(const GroupChatUser &other) const;
    bool operator!=(const GroupChatUser &other) const;
    bool operator<(const GroupChatUser &other) const;

    QString accountJid;
    QString chatJid;
    // The ID is part of the primary key in the database.
    // "" is used because a null string would otherwise be inserted as NULL into the database.
    QString id = QStringLiteral("");
    QString jid;
    QString name;
    Status status = Status::Joined;
};

Q_DECLARE_METATYPE(GroupChatUser)
