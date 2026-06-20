// SPDX-FileCopyrightText: 2024 Kaidan Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QXmppClientExtension.h>
#include <QXmppMessageHandler.h>

class MucController;
class QXmppOmemoManager;

// Registered before QXmppOmemoManager so it runs first.
// For OMEMO-encrypted groupchat (MUC) messages, sets mixUserJid to the real sender JID
// so the OMEMO manager uses the correct Double Ratchet session for decryption.
class MucOmemoPreprocessor : public QXmppClientExtension, public QXmppMessageHandler
{
    Q_OBJECT

public:
    explicit MucOmemoPreprocessor(MucController *mucController, QObject *parent = nullptr);

    void setOmemoManager(QXmppOmemoManager *manager);

    bool handleMessage(const QXmppMessage &message) override;

private:
    MucController *const m_mucController;
    QXmppOmemoManager *m_omemoManager = nullptr;
};
