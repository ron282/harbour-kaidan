// SPDX-FileCopyrightText: 2024 Kaidan Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "MucOmemoPreprocessor.h"

#include <QXmppMessage.h>
#include <QXmppUtils.h>

#if defined(SFOS)
#include <Omemo/QXmppOmemoManager.h>
#else
#include <QXmppOmemoManager.h>
#endif

#include "MucController.h"

MucOmemoPreprocessor::MucOmemoPreprocessor(MucController *mucController, QObject *parent)
    : QXmppClientExtension(), m_mucController(mucController)
{
    setParent(parent);
}

void MucOmemoPreprocessor::setOmemoManager(QXmppOmemoManager *manager)
{
    m_omemoManager = manager;
}

bool MucOmemoPreprocessor::handleMessage(const QXmppMessage &message)
{
    // Check type first to avoid touching the OMEMO manager for non-group messages.
    if (message.type() != QXmppMessage::GroupChat ||
        !message.mixUserJid().isEmpty() ||
        !m_omemoManager ||
        !m_omemoManager->isEncrypted(message)) {
        return false;
    }

    const auto occupantJid = message.from();
    const auto roomJid = QXmppUtils::jidToBareJid(occupantJid);
    const auto realBareJid = QXmppUtils::jidToBareJid(
        m_mucController->participantFullJid(roomJid, occupantJid));

    if (realBareJid.isEmpty())
        return false;

    // Re-inject a modified copy so QXmppOmemoManager decrypts with the correct sender session.
    //
    // In OMEMO V03 mode the decryptStanza() function builds a synthetic SCE envelope that has no
    // <to/> affix. A GroupChat-specific check then compares sceEnvelopeReader.to() (always "")
    // against jidToBareJid(stanza.from()) and aborts decryption if they differ.
    //
    // Workaround: clear `from` so jidToBareJid("") == "" == sceEnvelopeReader.to() → check passes.
    // The room JID is preserved in `to`, and the occupant nick in mixUserNick, so MessageHandler
    // can reconstruct chatJid and groupChatSenderId without the `from` field.
    QXmppMessage modified = message;
    modified.setMixUserJid(realBareJid);
    modified.setMixUserNick(QXmppUtils::jidToResource(occupantJid));
    modified.setFrom(QString());
    modified.setTo(roomJid);
    injectMessage(std::move(modified));

    return true;
}
