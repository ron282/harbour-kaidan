// SPDX-FileCopyrightText: 2022 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "RosterItemWatcher.h"
#include "RosterModel.h"

RosterItemNotifier &RosterItemNotifier::instance()
{
	static RosterItemNotifier notifier;
	return notifier;
}

void RosterItemNotifier::notifyWatchers(const QString &accountJid, const QString &jid, const std::optional<RosterItem> &item)
{
    for (int i = 0; i < m_itemWatchers.size(); ++i) {
        auto rosterItemWatcher = m_itemWatchers.at(i);
        if (rosterItemWatcher->accountJid() == accountJid && rosterItemWatcher->jid() == jid) {
            rosterItemWatcher->notify(item);
        }
	}
}

void RosterItemNotifier::registerItemWatcher(RosterItemWatcher *watcher)
{
    for (int i = 0; i < m_itemWatchers.size(); ++i) {
        if (m_itemWatchers.at(i) == watcher)
            return;
    }

    m_itemWatchers.append(watcher);
}

void RosterItemNotifier::unregisterItemWatcher(RosterItemWatcher *watcher)
{
    for (int i = 0; i < m_itemWatchers.size(); ++i) {
        if (m_itemWatchers.at(i) == watcher) {
            m_itemWatchers.removeAt(i);
            return;
        }
    }
}

RosterItemWatcher::RosterItemWatcher(QObject *parent)
	: QObject(parent)
{
}

RosterItemWatcher::~RosterItemWatcher()
{
	unregister();
}

const QString &RosterItemWatcher::accountJid() const
{
    return m_accountJid;
}

void RosterItemWatcher::setAccountJid(const QString &accountJid)
{
    if (accountJid != m_accountJid) {
        unregister();
        m_accountJid = accountJid;
        registerIfComplete();
        Q_EMIT accountJidChanged();
        notify(RosterModel::instance()->item(m_accountJid, m_jid));
    }
}

const QString &RosterItemWatcher::jid() const
{
	return m_jid;
}

void RosterItemWatcher::setJid(const QString &jid)
{
    if (jid != m_jid) {
        unregister();
        m_jid = jid;
        registerIfComplete();
        Q_EMIT jidChanged();
        notify(RosterModel::instance()->item(m_accountJid, m_jid));
    }
}

const RosterItem &RosterItemWatcher::item() const
{
	return m_item;
}

void RosterItemWatcher::registerIfComplete()
{
    if (!m_accountJid.isEmpty() && !m_jid.isEmpty()) {
        RosterItemNotifier::instance().registerItemWatcher(this);
    }
}

void RosterItemWatcher::unregister()
{
    if (!m_accountJid.isNull() && !m_jid.isNull()) {
        RosterItemNotifier::instance().unregisterItemWatcher(this);
    }
}

void RosterItemWatcher::notify(const std::optional<RosterItem> &item)
{
    if (item) {
        m_item = *item;
    } else {
        m_item = {};
    }

    Q_EMIT itemChanged();
}

#include "moc_RosterItemWatcher.cpp"
