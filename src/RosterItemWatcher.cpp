/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

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
			} else {
				i++;
			}
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
		emit jidChanged();
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
	emit itemChanged();
}
