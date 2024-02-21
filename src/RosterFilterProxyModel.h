// SPDX-FileCopyrightText: 2019 Robert Maerkisch <zatrox@kaidan.im>
// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QSortFilterProxyModel>

class RosterFilterProxyModel : public QSortFilterProxyModel
{
	Q_OBJECT

	Q_PROPERTY(bool onlyAvailableContactsShown READ onlyAvailableContactsShown WRITE setOnlyAvailableContactsShown NOTIFY onlyAvailableContactsShownChanged)
#if defined(SFOS)
	Q_PROPERTY(QList<QString> selectedAccountJids READ selectedAccountJids WRITE setSelectedAccountJids NOTIFY selectedAccountJidsChanged)
	Q_PROPERTY(QList<QString> selectedGroups READ selectedGroups WRITE setSelectedGroups NOTIFY selectedGroupsChanged)
#else
	Q_PROPERTY(QVector<QString> selectedAccountJids READ selectedAccountJids WRITE setSelectedAccountJids NOTIFY selectedAccountJidsChanged)
	Q_PROPERTY(QVector<QString> selectedGroups READ selectedGroups WRITE setSelectedGroups NOTIFY selectedGroupsChanged)
#endif

public:
	RosterFilterProxyModel(QObject *parent = nullptr);

	void setOnlyAvailableContactsShown(bool onlyAvailableContactsShown);
	bool onlyAvailableContactsShown() const;
	Q_SIGNAL void onlyAvailableContactsShownChanged();


#if defined(SFOS)
	void setSelectedAccountJids(const QList<QString> &selectedAccountJids);
	QList<QString> selectedAccountJids() const;
#else
	void setSelectedAccountJids(const QVector<QString> &selectedAccountJids);
	QVector<QString> selectedAccountJids() const;
#endif
	Q_SIGNAL void selectedAccountJidsChanged();

#if defined(SFOS)
	void setSelectedGroups(const QList<QString> &selectedGroups);
	QList<QString> selectedGroups() const;
#else
	void setSelectedGroups(const QVector<QString> &selectedGroups);
	QVector<QString> selectedGroups() const;
#endif
	Q_SIGNAL void selectedGroupsChanged();

	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
	QVector<QString> m_selectedAccountJids;
	QVector<QString> m_selectedGroups;
	bool m_onlyAvailableContactsShown = false;
};
