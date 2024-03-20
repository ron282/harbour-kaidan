// SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Qt
#ifndef SFOS
#include <QRandomGenerator>
#endif
#if defined (SFOS)
#include "../3rdparty/QEmuStringView/qemustringview.h"
#endif
// Kaidan
#include "CredentialsGenerator.h"
#include "Globals.h"

static const QLatin1String VOWELS = QLatin1String("aeiou");
static const int VOWELS_LENGTH = VOWELS.size();

static const QLatin1String CONSONANTS = QLatin1String("bcdfghjklmnpqrstvwxyz");
static const int CONSONANTS_LENGTH = CONSONANTS.size();

CredentialsGenerator::CredentialsGenerator(QObject *parent)
	: QObject(parent)
{
}

QString CredentialsGenerator::generatePronounceableName(unsigned int length)
{
	QString randomString;
	randomString.reserve(length);
#if SFOS    
	bool startWithVowel = abs(qrand()) % 2;
#else
    bool startWithVowel = QRandomGenerator::global()->generate() % 2;
#endif
	length += startWithVowel;
	for (unsigned int i = startWithVowel; i < length; ++i) {
		if (i % 2)
#if SFOS    
			randomString.append(VOWELS.data()[abs(qrand()) % VOWELS_LENGTH]);
#else
            randomString.append(VOWELS.at(QRandomGenerator::global()->generate() % VOWELS_LENGTH));
#endif
		else
#if SFOS    
			randomString.append(CONSONANTS.data()[abs(qrand()) % CONSONANTS_LENGTH]);
#else
            randomString.append(CONSONANTS.at(QRandomGenerator::global()->generate() % CONSONANTS_LENGTH));
#endif
	}
	return randomString;
}

QString CredentialsGenerator::generateUsername()
{
	return generatePronounceableName(GENERATED_USERNAME_LENGTH);
}

QString CredentialsGenerator::generatePassword()
{
#if SFOS    
	return generatePassword(GENERATED_PASSWORD_LENGTH_LOWER_BOUND + abs(qrand()) % (GENERATED_PASSWORD_LENGTH_UPPER_BOUND - GENERATED_PASSWORD_LENGTH_LOWER_BOUND + 1));
#else
    return generatePassword(GENERATED_PASSWORD_LENGTH_LOWER_BOUND + QRandomGenerator::global()->generate() % (GENERATED_PASSWORD_LENGTH_UPPER_BOUND - GENERATED_PASSWORD_LENGTH_LOWER_BOUND + 1));
#endif
}

QString CredentialsGenerator::generatePassword(unsigned int length)
{
	QString password;
	password.reserve(length);

	for (unsigned int i = 0; i < length; i++)
#if SFOS    
		password.append(GENERATED_PASSWORD_ALPHABET.data()[abs(qrand()) % GENERATED_PASSWORD_ALPHABET_LENGTH]);
#else
        password.append(GENERATED_PASSWORD_ALPHABET.at(QRandomGenerator::global()->generate() % GENERATED_PASSWORD_ALPHABET_LENGTH));
#endif
	return password;
}
