// SPDX-FileCopyrightText: 2022 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "FileProgressCache.h"

#include <QCoreApplication>

#if defined(SFOS)
#include <QDebug>
#define QSTRINGVIEW_EMULATE
#include "../3rdparty/QEmuStringView/qemustringview.h"
#endif

#if defined(SFOS)
#include <QTimer>
#include <functional>
#endif

FileProgressWatcher::FileProgressWatcher(QObject *parent)
	: QObject(parent)
{
}

FileProgressWatcher::~FileProgressWatcher() = default;

QString FileProgressWatcher::fileId() const
{
	return QString::number(m_key.value_or(0));
}

void FileProgressWatcher::setFileId(const QString &fileId)
{
	qint64 fId = fileId.toLongLong();
	if (!m_key || (m_key && *m_key != fId)) {
		setKey(std::move(fId));
		emit fileIdChanged();

		auto progress = FileProgressCache::instance().progress(*m_key);
		m_loading = progress.has_value();
		m_progress = progress.value_or(FileProgress());
		emit progressChanged();
	}
}

void FileProgressWatcher::notify(const std::optional<FileProgress> &value)
{
	m_loading = value.has_value();
	m_progress = value.value_or(FileProgress());
	emit progressChanged();
}

FileProgressCache::FileProgressCache() = default;

FileProgressCache::~FileProgressCache()
{
	// wait for other threads to finish
	std::scoped_lock locker(m_mutex);
}

FileProgressCache &FileProgressCache::instance()
{
	static FileProgressCache cache;
	return cache;
}

std::optional<FileProgress> FileProgressCache::progress(qint64 fileId)
{
	std::scoped_lock locker(m_mutex);
	if (auto itr = m_files.find(fileId); itr != m_files.end()) {
		return itr->second;
	}
	return {};
}

void FileProgressCache::reportProgress(qint64 fileId, std::optional<FileProgress> progress)
{
	std::scoped_lock locker(m_mutex);
	if (progress) {
		m_files.insert_or_assign(fileId, *progress);
	} else {
		m_files.erase(fileId);
	}

#if defined(SFOS)
    // any thread
    QTimer* timer = new QTimer();
    timer->moveToThread(QCoreApplication::instance()->thread());
    timer->setSingleShot(true);
    QObject::connect(timer, &QTimer::timeout, [timer, fileId, progress]()
    {
        // main thread
		FileProgressNotifier::instance().notifyWatchers(fileId, progress);
        timer->deleteLater();
    });
    QMetaObject::invokeMethod(timer, "start", Qt::QueuedConnection, Q_ARG(int, 0));
#else
	// watchers live on main thread
	QMetaObject::invokeMethod(QCoreApplication::instance(), [fileId, progress] {
		FileProgressNotifier::instance().notifyWatchers(fileId, progress);
	});
#endif
}
