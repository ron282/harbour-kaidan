// SPDX-FileCopyrightText: 2022 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "RosterItemWatcher.h"
#ifndef UNIT_TEST
#include "RosterModel.h"
#endif

RosterItemNotifier &RosterItemNotifier::instance()
{
	static RosterItemNotifier notifier;
	return notifier;
}

void RosterItemNotifier::notifyWatchers(const QString &jid, const std::optional<RosterItem> &item)
{
#if defined(SFOS)
	auto list = m_itemWatchers.values(jid);
	for (int i = 0; i < list.size(); ++i) {
		list[i]->notify(item);
	}
#else
	auto [keyBegin, keyEnd] = m_itemWatchers.equal_range(jid);
	std::for_each(keyBegin, keyEnd, [&](const auto &pair) {
		pair.second->notify(item);
	});
#endif
}

void RosterItemNotifier::registerItemWatcher(const QString &jid, RosterItemWatcher *watcher)
{
#if defined(SFOS)
	m_itemWatchers.insert(jid, watcher);
#else
	m_itemWatchers.emplace(jid, watcher);
#endif
}

void RosterItemNotifier::unregisterItemWatcher(const QString &jid, RosterItemWatcher *watcher)
{
#if defined(SFOS)
	auto list = m_itemWatchers.values(jid);
	int i = 0;
    while(i < list.size()) {
		if(list[i] == watcher) {
			if(m_itemWatchers.remove(jid) > 1) {
				list = m_itemWatchers.values(jid);
				i = 0;	
            }
            else {
                i++;
            }
        }
        else {
            i++;
        }
	}
#else
	auto [keyBegin, keyEnd] = m_itemWatchers.equal_range(jid);
	auto itr = std::find_if(keyBegin, keyEnd, [watcher](const auto &pair) {
		return pair.second == watcher;
	});
	if (itr != keyEnd) {
		m_itemWatchers.erase(itr);
	}
#endif
}

RosterItemWatcher::RosterItemWatcher(QObject *parent)
	: QObject(parent)
{
}

RosterItemWatcher::~RosterItemWatcher()
{
	unregister();
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
		RosterItemNotifier::instance().registerItemWatcher(m_jid, this);
		Q_EMIT jidChanged();
#ifndef UNIT_TEST
		notify(RosterModel::instance()->findItem(m_jid));
#endif
    }
}

const RosterItem &RosterItemWatcher::item() const
{
	return m_item;
}

void RosterItemWatcher::unregister()
{
	if (!m_jid.isNull()) {
		RosterItemNotifier::instance().unregisterItemWatcher(m_jid, this);
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
