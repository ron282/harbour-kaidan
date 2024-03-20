// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2023 Tibor Csötönyi <work@taibsu.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "ProviderListItem.h"
// Qt
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#if defined(SFOS)
#include <QLocale>
#include <QMap>
#include <QString>
#endif
// Kaidan
#include "Algorithms.h"

#define REGIONAL_INDICATOR_SYMBOL_BASE 0x1F1A5

//<<<<<<< HEAD
//template<typename T>
//struct LanguageMap
//{
//	T pickBySystemLocale() const
//	{
//		auto languageCode = QLocale::system().name().split(u'_').first();

//		// Use the system-wide language chat support jid if available.
//		auto resultItr = values.find(languageCode);
//#if defined(SFOS)
//		if (resultItr != values.end() && !(++resultItr)->isEmpty()) {
//			return *resultItr;
//		}
//#else
//		if (resultItr != values.end() && !resultItr->second.isEmpty()) {
//			return resultItr->second;
//		}
//#endif

//		// Use the English chat support jid if no system-wide language chat support jid is available but English is.
//		resultItr = values.find(QStringLiteral("EN"));
//#if defined(SFOS)
//		if (resultItr != values.end() && !(++resultItr)->isEmpty()) {
//			return *resultItr;
//		}
//#else
//		if (resultItr != values.end() && !resultItr->second.isEmpty()) {
//			return resultItr->second;
//		}
//#endif

//		// Use the first chat support jid if also no English version is available but another one is.
//		if (!values.empty()) {
//#if defined(SFOS)
//			return *(++values.begin());
//#else
//			return values.begin()->second;
//#endif
//		}

//		return {};
//	}

//#if defined(SFOS)
//	QMap<QString, T> values;
//#else
//	std::unordered_map<QString, T> values;
//#endif
//};

//=======
//>>>>>>> 40f086ac4f72fda8b541a021a1f497d5c081247e
class ProviderListItemPrivate : public QSharedData
{
public:
	ProviderListItemPrivate();

	bool isCustomProvider;
	QString jid;
	bool supportsInBandRegistration;
	ProviderListItem::LanguageVariants<QUrl> registrationWebPages;
	QVector<QString> languages;
	QVector<QString> countries;
	ProviderListItem::LanguageVariants<QUrl> websites;
	int onlineSince;
	int httpUploadSize;
	int messageStorageDuration;
	ProviderListItem::LanguageVariants<QVector<QString>> chatSupport;
	ProviderListItem::LanguageVariants<QVector<QString>> groupChatSupport;
};

ProviderListItemPrivate::ProviderListItemPrivate()
	: isCustomProvider(false), supportsInBandRegistration(false), onlineSince(-1), httpUploadSize(-1), messageStorageDuration(-1)
{
}

ProviderListItem ProviderListItem::fromJson(const QJsonObject &object)
{
	ProviderListItem item;
	item.setIsCustomProvider(false);
	item.setJid(object.value(QLatin1String("jid")).toString());
	item.setSupportsInBandRegistration(object.value(QLatin1String("inBandRegistration")).toBool());
	item.setRegistrationWebPages(parseStringLanguageVariants<QUrl>(object.value(QLatin1String("registrationWebPage")).toObject()));

	const auto serverLocations = object.value(QLatin1String("serverLocations")).toArray();
	QVector<QString> countries;
	for (const auto &country : serverLocations) {
		countries.append(country.toString().toUpper());
	}
	item.setCountries(countries);

	item.setWebsites(parseStringLanguageVariants<QUrl>(object.value(QLatin1String("website")).toObject()));
	item.setOnlineSince(object.value(QLatin1String("since")).toInt(-1));
	item.setHttpUploadSize(object.value(QLatin1String("maximumHttpFileUploadFileSize")).toInt(-1));
	item.setMessageStorageDuration(object.value(QLatin1String("maximumMessageArchiveManagementStorageTime")).toInt(-1));
//<<<<<<< HEAD

//	const auto chatSupportLanguageAddresses = object.value(QLatin1String("chatSupport")).toObject();
//	for (auto itr = chatSupportLanguageAddresses.constBegin(); itr != chatSupportLanguageAddresses.constEnd(); ++itr) {
//#if defined(SFOS)
//		item.d->chatSupport.values.insert(
//#else
//		item.d->chatSupport.values.insert_or_assign(
//#endif
//			itr.key().toUpper(),
//			transform(itr.value().toArray(), [](auto item) { return item.toString(); })
//		);
//	}

//	const auto groupChatSupportLanguageAddresses = object.value(QLatin1String("groupChatSupport")).toObject();
//	for (auto itr = groupChatSupportLanguageAddresses.constBegin(); itr != groupChatSupportLanguageAddresses.constEnd(); ++itr) {
//#if defined(SFOS)
//		item.d->groupChatSupport.values.insert(
//#else
//		item.d->groupChatSupport.values.insert_or_assign(
//#endif
//			itr.key().toUpper(),
//			transform(itr.value().toArray(), [](auto item) { return item.toString(); })
//		);
//	}
//=======
	item.setChatSupport(parseStringListLanguageVariants<QVector<QString>>(object.value(QLatin1String("chatSupport")).toObject()));
	item.setGroupChatSupport(parseStringListLanguageVariants<QVector<QString>>(object.value(QLatin1String("groupChatSupport")).toObject()));
//>>>>>>> 40f086ac4f72fda8b541a021a1f497d5c081247e

	return item;
}

ProviderListItem::ProviderListItem(bool isCustomProvider)
	: d(new ProviderListItemPrivate)
{
	d->isCustomProvider = isCustomProvider;
}

ProviderListItem::ProviderListItem(const ProviderListItem& other) = default;

ProviderListItem::~ProviderListItem() = default;

ProviderListItem & ProviderListItem::operator=(const ProviderListItem& other) = default;

bool ProviderListItem::isCustomProvider() const
{
	return d->isCustomProvider;
}

void ProviderListItem::setIsCustomProvider(bool isCustomProvider)
{
	d->isCustomProvider = isCustomProvider;
}

QString ProviderListItem::jid() const
{
	return d->jid;
}

void ProviderListItem::setJid(const QString &jid)
{
	d->jid = jid;
}

bool ProviderListItem::supportsInBandRegistration() const
{
	return d->supportsInBandRegistration;
}

void ProviderListItem::setSupportsInBandRegistration(bool supportsInBandRegistration)
{
	d->supportsInBandRegistration = supportsInBandRegistration;
}

ProviderListItem::LanguageVariants<QUrl> ProviderListItem::registrationWebPages() const
{
	return d->registrationWebPages;
}

void ProviderListItem::setRegistrationWebPages(const LanguageVariants<QUrl> &registrationWebPages)
{
	d->registrationWebPages = registrationWebPages;
}

QVector<QString> ProviderListItem::languages() const
{
#if defined(SFOS)
	QVector<QString> rv;

	QMapIterator<QString, QUrl> i(d->websites);
	while (i.hasNext()) {
	    i.next();
	    rv.append(i.key());
	}
	return rv;
#else
	return { d->websites.keyBegin(), d->websites.keyEnd() };
#endif
}

QVector<QString> ProviderListItem::countries() const
{
	return d->countries;
}

void ProviderListItem::setCountries(const QVector<QString> &countries)
{
	d->countries = countries;
}

QVector<QString> ProviderListItem::flags() const
{
	// If this object is the custom provider, no flag should be shown.
	if (d->isCustomProvider)
		return {};

	// If no country is specified, return a flag for an unknown country.
	if (d->countries.isEmpty()) {
		return { QStringLiteral("🏳️‍🌈") };
	}

	QVector<QString> flags;
	for (const auto &country : std::as_const(d->countries)) {
		QString flag;

		// Iterate over the characters of the country string.
		// Example: For the country string "DE", the loop iterates over the characters "D" and "E".
		// An emoji flag sequence (i.e. the flag of the corresponding country / region) is represented by two regional indicator symbols.
		// Example: 🇩 (U+1F1E9 = 0x1F1E9 = 127465) and 🇪 (U+1F1EA = 127466) concatenated result in 🇩🇪.
		// Each regional indicator symbol is created by a string which has the following Unicode code point:
		// REGIONAL_INDICATOR_SYMBOL_BASE + unicode code point of the character of the country string.
		// Example: 127397 (REGIONAL_INDICATOR_SYMBOL_BASE) + 68 (unicode code point of "D") = 127465 for 🇩
		//
		// QString does not provide creating a string by its corresponding Unicode code point.
		// Therefore, QChar must be used to create a character by its Unicode code point.
		// Unfortunately, that cannot be done in one step because QChar does not support creating Unicode characters greater than 16 bits.
		// For this reason, each character of the country string is split into two parts.
		// Each part consists of 16 bits of the original character.
		// The first and the second part are then merged into one string.
		//
		// Finally, the string consisting of the first regional indicator symbol and the string consisting of the second one are concatenated.
		// The resulting string represents the emoji flag sequence.
		for (const auto &character : country) {
			auto regionalIncidatorSymbolCodePoint = REGIONAL_INDICATOR_SYMBOL_BASE + character.unicode();
			QChar regionalIncidatorSymbolParts[2];
			regionalIncidatorSymbolParts[0] = QChar::highSurrogate(regionalIncidatorSymbolCodePoint);
			regionalIncidatorSymbolParts[1] = QChar::lowSurrogate(regionalIncidatorSymbolCodePoint);

			auto regionalIncidatorSymbol = QString(regionalIncidatorSymbolParts, 2);
			flag.append(regionalIncidatorSymbol);
		}

		flags.append(flag);
	}

	return flags;
}

ProviderListItem::LanguageVariants<QUrl> ProviderListItem::websites() const
{
	return d->websites;
}

void ProviderListItem::setWebsites(const LanguageVariants<QUrl> &websites)
{
	d->websites = websites;
}

QUrl ProviderListItem::chosenWebsite() const
{
	return websites().pickBySystemLocale();
}

int ProviderListItem::onlineSince() const
{
	return d->onlineSince;
}

void ProviderListItem::setOnlineSince(int onlineSince)
{
	d->onlineSince = onlineSince;
}

int ProviderListItem::httpUploadSize() const
{
	return d->httpUploadSize;
}

void ProviderListItem::setHttpUploadSize(int httpUploadSize)
{
	d->httpUploadSize = httpUploadSize;
}

int ProviderListItem::messageStorageDuration() const
{
	return d->messageStorageDuration;
}

void ProviderListItem::setMessageStorageDuration(int messageStorageDuration)
{
	d->messageStorageDuration = messageStorageDuration;
}

ProviderListItem::LanguageVariants<QVector<QString>> ProviderListItem::chatSupport() const
{
	return d->chatSupport;
}

void ProviderListItem::setChatSupport(const LanguageVariants<QVector<QString>> &chatSupport)
{
	d->chatSupport = chatSupport;
}

QVector<QString> ProviderListItem::chosenChatSupport() const
{
	return chatSupport().pickBySystemLocale();
}

//<<<<<<< HEAD
//#if defined(SFOS)
//void ProviderListItem::setChatSupport(QMap<QString, QVector<QString>> &&chatSupport)
//#else
//void ProviderListItem::setChatSupport(std::unordered_map<QString, QVector<QString>> &&chatSupport)
//#endif
//=======
ProviderListItem::LanguageVariants<QVector<QString>> ProviderListItem::groupChatSupport() const
//>>>>>>> 40f086ac4f72fda8b541a021a1f497d5c081247e
{
	return d->groupChatSupport;
}

void ProviderListItem::setGroupChatSupport(const LanguageVariants<QVector<QString>> &groupChatSupport)
{
	d->groupChatSupport = groupChatSupport;
}

//<<<<<<< HEAD
//#if defined(SFOS)
//void ProviderListItem::setGroupChatSupport(QMap<QString, QVector<QString>> &&groupChatSupport)
//#else
//void ProviderListItem::setGroupChatSupport(std::unordered_map<QString, QVector<QString>> &&groupChatSupport)
//#endif
//=======
QVector<QString> ProviderListItem::chosenGroupChatSupport() const
//>>>>>>> 40f086ac4f72fda8b541a021a1f497d5c081247e
{
	return groupChatSupport().pickBySystemLocale();
}

bool ProviderListItem::operator<(const ProviderListItem& other) const
{
	return d->jid < other.jid();
}

bool ProviderListItem::operator>(const ProviderListItem& other) const
{
	return d->jid > other.jid();
}

bool ProviderListItem::operator<=(const ProviderListItem& other) const
{
	return d->jid <= other.jid();
}

bool ProviderListItem::operator>=(const ProviderListItem& other) const
{
	return d->jid >= other.jid();
}

bool ProviderListItem::operator==(const ProviderListItem& other) const
{
	return d == other.d;
}

//<<<<<<< HEAD
//#if defined(SFOS)
//QStringList ProviderListItem::chatSupportList() const
//{
//    QStringList retVal;

//    auto it = d->chatSupport.pickBySystemLocale().cbegin();

//    while(it != d->chatSupport.pickBySystemLocale().cend())
//    {
//        retVal.append(*it);
//        ++it;
//    }
//    return retVal;
//}

//QStringList ProviderListItem::groupChatSupportList() const
//{
//    QStringList retVal;

//    auto it = d->groupChatSupport.pickBySystemLocale().cbegin();

//    while(it != d->groupChatSupport.pickBySystemLocale().cend())
//    {
//        retVal.append(*it);
//        ++it;
//    }
//    return retVal;
//}
//#endif
//=======
template<typename T>
ProviderListItem::LanguageVariants<T> ProviderListItem::parseStringLanguageVariants(const QJsonObject &stringLanguageVariants)
{
#if defined(SFOS)
    ProviderListItem::LanguageVariants<T> parsedLanguageVariants;

    for (auto itr = stringLanguageVariants.constBegin(); itr != stringLanguageVariants.constEnd(); ++itr) {
        const auto language = itr.key().toUpper();
        const T languageVariant = T { itr.value().toString() };
        parsedLanguageVariants.insert(language, languageVariant);
    }

    return parsedLanguageVariants;
#else
	return parseLanguageVariants<T>(stringLanguageVariants, [](const QJsonValue &value) {
		return T { value.toString() };
	});
#endif
}

template<typename T>
ProviderListItem::LanguageVariants<T> ProviderListItem::parseStringListLanguageVariants(const QJsonObject &stringListLanguageVariants)
{
#if defined(SFOS)
    ProviderListItem::LanguageVariants<T> parsedLanguageVariants;

    for (auto itr = stringListLanguageVariants.constBegin(); itr != stringListLanguageVariants.constEnd(); ++itr) {
        const auto language = itr.key().toUpper();
        const T languageVariant =  T { transform(itr.value().toArray(), [](const QJsonValue &item) { return item.toString(); }) };
        parsedLanguageVariants.insert(language, languageVariant);
    }

    return parsedLanguageVariants;
#else
    return parseLanguageVariants<T>(stringListLanguageVariants, [](const QJsonValue &value) {
		return T { transform(value.toArray(), [](const QJsonValue &item) { return item.toString(); }) };
	});
#endif
}

#if !defined(SFOS)
template<typename T>
ProviderListItem::LanguageVariants<T> ProviderListItem::parseLanguageVariants(const QJsonObject &languageVariants, const std::function<T (const QJsonValue &)> &convertToTargetType)
{
	ProviderListItem::LanguageVariants<T> parsedLanguageVariants;

	for (auto itr = languageVariants.constBegin(); itr != languageVariants.constEnd(); ++itr) {
		const auto language = itr.key().toUpper();
		const T languageVariant = convertToTargetType(itr.value());
		parsedLanguageVariants.insert(language, languageVariant);
	}

	return parsedLanguageVariants;
}
#endif
//>>>>>>> 40f086ac4f72fda8b541a021a1f497d5c081247e
