<!--
SPDX-FileCopyrightText: 2016 Linus Jahn <lnj@kaidan.im>

SPDX-License-Identifier: CC0-1.0
-->

# Kaidan - User-friendly and modern chat app for every device

[![Kaidan MUC](https://search.jabbercat.org/api/1.0/badge?address=kaidan@muc.kaidan.im)](https://i.kaidan.im)
[![license](https://img.shields.io/badge/License-GPLv3%2B%20%2F%20CC%20BY--SA%204.0-blue.svg)](https://raw.githubusercontent.com/kaidanim/kaidan/master/LICENSE)
[![Donations](https://img.shields.io/liberapay/patrons/kaidan.svg?logo=liberapay)](https://liberapay.com/kaidan)

![Kaidan screenshot](https://www.kaidan.im/images/screenshot.png)

<a href="https://repology.org/project/kaidan/versions">
    <img src="https://repology.org/badge/vertical-allrepos/kaidan.svg" alt="Packaging status" align="right">
</a>

## About

SailKaidan is based on [Kaidan][kaidan-website]. 

[Kaidan][kaidan-website] is a simple, user-friendly and modern chat client. It
uses the open communication protocol [XMPP (Jabber)][xmpp]. The user interface
makes use of [Silica][silica-website] and [QtQuick][qtquick], while the
back-end of Kaidan is entirely written in C++ using [Qt][qt] and the Qt-based
XMPP library [QXmpp][qxmpp].
7
SailKaidan runs on SailfishOS. 

SailKaidan does *not* have all basic features yet and has still some stability
issues. Do not expect it to be as good as the currently dominating instant
messaging clients.

If you are interested in the technical features, you can have a
look at Kaidan's [overview page][overview] including XEPs and RFCs.

## Using and Building Kaidan

Downloadable builds are available on [Openrepos.net][downloads].

## How to compile
* Install SFDK development tools

* Install SFOS devices
Need to open QtCreator and to install a device. You need to enable Development tools on your device. 

* Create a directory for output rpm packages
mkdir /home/user/dev/RPMS
sfdk config --global --push output-target "/home/user/dev/RPMS"

* Configure SFDK tools
sfdk tools list
sfdk config --global --push target "SailfishOS-4.5.0.18-aarch64"
sfdk device list
sfdk config --global --push device "Xperia 10 III (ARM 64bit)"

* Clone repositories for compilation
cd dev
git clone https://github.com/ron282/libomemo-c.git
git clone https://github.com/ron282/qca.git
git clone https://github.com/ron282/qxmpp.git 
git clone https://github.com/ron282/harbour-kaidan.git

* Compile sources
cd libomemo-c
sfdk build
cd ../qca
sfdk build
cd ../qxmpp
git checkout 1.5
sfdk build
cd ../harbour-kaidan
git checkout sfos
sfdk build

Note: to compile harbour-kaidan you can also open kaidan.pro under QtCreator

## How to deploy on a SFOS device

Be sure your device has been registered with QtCreator and sfdk
configured to use it 

cd ../libomemo-c
sfdk deploy --sdk omemo-c
cd ../qca
sfdk deploy --sdk qca
cd ../qxmpp
sfdk deploy --sdk QXmpp
cd ../harbour-kaidan
sfdk deploy --sdk 

## How to compile for another target
sfdk config --global --push target "SailfishOS-4.5.0.18-aarch64"
sfdk config --global --push device "Xperia 10 III (ARM 64bit)"

cd ../libomemo-c
rm -rf build
sfdk deploy --sdk omemo-c
cd ../qca
rm -rf build
sfdk deploy --sdk qca
cd ../qxmpp
rm -rf build
sfdk deploy --sdk QXmpp
cd ../harbour-kaidan
rm *.o
sfdk build

## Dependencies

Here are the general dependencies of Kaidan:
 * [Qt][qt-build-sources] (Core Concurrent Qml Quick Svg Sql QuickControls2 Xml Multimedia Positioning Location) (>= 5.6.0)
 * [QXmpp][qxmpp] (with OMEMO) (>= 1.5.0)
 * [ZXing-cpp][zxing-cpp] (>= 1.1.1)
 
[downloads]: https://www.openrepos.net/content/ron282/sailkaidan
[ecm]: https://api.kde.org/ecm/manual/ecm.7.html
[kaidan-website]: https://kaidan.im
[kaidan-website-repo]: https://invent.kde.org/websites/kaidan-im
[qt]: https://www.qt.io/
[qt-build-sources]: https://doc.qt.io/qt-5/build-sources.html
[qtquick]: https://wiki.qt.io/Qt_Quick
[qxmpp]: https://github.com/qxmpp-project/qxmpp
[overview]: https://xmpp.org/software/clients/kaidan/
[xmpp]: https://xmpp.org
[zxing-cpp]: https://github.com/nu-book/zxing-cpp
[securitytxt]: https://www.kaidan.im/.well-known/security.txt
[kdesecurity]: https://kde.org/info/security/
[silica-website]: https://sailfishos.org/develop/docs/silica/
