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
#if defined(SFOS)
#include "../3rdparty/QEmuStringView/qemustringview.h"
#include "../3rdparty/QImagePainter/qimagepainter.h"
#endif

#if defined(SFOS)
#include <sailfishapp.h>
#include <QQuickView>
#include <QQmlContext>
#endif

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QDebug>
#include <QDir>
#include <QIcon>
#include <QLibraryInfo>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <qqml.h>

#if defined(SFOS)
//#include <QMimeType>
//Q_DECLARE_METATYPE(QMimeType)
//Q_DECLARE_METATYPE(QMetaTypeId<QMimeType>)
#endif

// QXmpp
#include <QXmppClient.h>
#include <QXmppDiscoveryIq.h>
#include <QXmppVCardIq.h>
#include <QXmppRegisterIq.h>
#include <QXmppResultSet.h>
#include <QXmppVersionIq.h>

#include "qxmpp-exts/QXmppUri.h"

// Kaidan
#include "AccountManager.h"
#include "AudioDeviceModel.h"
#include "AvatarFileStorage.h"
#include "BitsOfBinaryImageProvider.h"
#include "CameraModel.h"
#include "CredentialsGenerator.h"
#include "CredentialsValidator.h"
#include "DataFormModel.h"
#include "DiscoveryManager.h"
#include "EmojiModel.h"
#include "Encryption.h"
#include "Enums.h"
#include "FileProgressCache.h"
#include "FileSharingController.h"
#include "GuiStyle.h"
#include "HostCompletionModel.h"
#include "HostCompletionProxyModel.h"
#include "Kaidan.h"
#include "MediaUtils.h"
#include "MediaRecorder.h"
#include "Message.h"
#include "MessageComposition.h"
#include "MessageModel.h"
#include "MessageHandler.h"
#include "OmemoManager.h"
#include "OmemoWatcher.h"
#include "PublicGroupChatModel.h"
#include "PublicGroupChatProxyModel.h"
#include "PublicGroupChatSearchManager.h"
#include "QmlUtils.h"
#include "QrCodeGenerator.h"
#include "QrCodeScannerFilter.h"
#include "RegistrationDataFormFilterModel.h"
#include "RegistrationManager.h"
#include "RosterItemWatcher.h"
#include "RosterManager.h"
#include "RosterModel.h"
#include "RosterFilterProxyModel.h"
#include "ServerFeaturesCache.h"
#include "ProviderListModel.h"
#include "StatusBar.h"
#include "UserDevicesModel.h"
#include "VCardModel.h"
#include "VCardManager.h"
#include "VersionManager.h"
#include "RecentPicturesModel.h"
#include "NotificationsMutedWatcher.h"

Q_DECLARE_METATYPE(Qt::ApplicationState)

Q_DECLARE_METATYPE(QXmppClient::State)
Q_DECLARE_METATYPE(QXmppMessage::State)
Q_DECLARE_METATYPE(QXmppDiscoveryIq);
Q_DECLARE_METATYPE(QXmppPresence)
Q_DECLARE_METATYPE(QXmppStanza::Error)
Q_DECLARE_METATYPE(QXmppResultSetReply);
Q_DECLARE_METATYPE(QXmpp::TrustLevel);
Q_DECLARE_METATYPE(QXmppUri)
Q_DECLARE_METATYPE(QXmppVCardIq)
Q_DECLARE_METATYPE(QXmppVersionIq)

Q_DECLARE_METATYPE(std::function<void()>)
Q_DECLARE_METATYPE(std::function<void(RosterItem&)>)
Q_DECLARE_METATYPE(std::function<void(Message&)>)

#ifdef STATIC_BUILD
#include "static_plugins.h"
#endif

#ifndef QAPPLICATION_CLASS
#define QAPPLICATION_CLASS QApplication
#endif
#include QT_STRINGIFY(QAPPLICATION_CLASS)

#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID) && !defined(SFOS)
// SingleApplication (Qt5 replacement for QtSingleApplication)
#include "singleapp/singleapplication.h"
#endif

#ifdef STATIC_BUILD
#define KIRIGAMI_BUILD_TYPE_STATIC
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#endif

#ifdef Q_OS_WIN
#include <windows.h>
#endif

enum CommandLineParseResult {
	CommandLineOk,
	CommandLineError,
	CommandLineVersionRequested,
	CommandLineHelpRequested
};

CommandLineParseResult parseCommandLine(QCommandLineParser &parser, QString *errorMessage)
{
	// application description
	parser.setApplicationDescription("APPLICATION_DISPLAY_NAME - APPLICATION_DESCRIPTION");

	// add all possible arguments
	QCommandLineOption helpOption = parser.addHelpOption();
	QCommandLineOption versionOption = parser.addVersionOption();
	parser.addOption({"disable-xml-log", "Disable output of full XMPP XML stream."});
#ifndef NDEBUG
	parser.addOption({{"m", "multiple"}, "Allow multiple instances to be started."});
#endif
	parser.addPositionalArgument("xmpp-uri", "An XMPP-URI to open (i.e. join a chat).",
	                             "[xmpp-uri]");

	// parse arguments
	if (!parser.parse(QGuiApplication::arguments())) {
		*errorMessage = parser.errorText();
		return CommandLineError;
	}

	// check for special cases
	if (parser.isSet(versionOption))
		return CommandLineVersionRequested;

	if (parser.isSet(helpOption))
		return CommandLineHelpRequested;
	// if nothing special happened, return OK
	return CommandLineOk;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN
	if (AttachConsole(ATTACH_PARENT_PROCESS)) {
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
	}
#endif

	//
	// App
	//

#ifdef UBUNTU_TOUCH
	qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "true");
	qputenv("QT_QUICK_CONTROLS_MOBILE", "true");
#endif

#ifdef APPIMAGE
	qputenv("OPENSSL_CONF", "");
#endif

#ifndef SFOS
	// name, display name, description
	QGuiApplication::setApplicationName(APPLICATION_NAME);
	QGuiApplication::setApplicationDisplayName(APPLICATION_DISPLAY_NAME);
	QGuiApplication::setApplicationVersion(VERSION_STRING);
    QGuiApplication::setDesktopFileName("im.kaidan.kaidan");
	// attributes
	QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif

	// create a qt app
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
	QGuiApplication app(argc, argv);
#elif defined(SFOS)
    QGuiApplication *pApp = NULL;
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
    pApp = app;
#else
	SingleApplication app(argc, argv, true);
#endif

#ifdef APPIMAGE
	QFileInfo executable(QCoreApplication::applicationFilePath());

	if (executable.isSymLink()) {
		executable.setFile(executable.symLinkTarget());
	}

	QString gstreamerPluginsPath;

	// Try to use deployed plugins if any...
#if defined(TARGET_GSTREAMER_PLUGINS)
	gstreamerPluginsPath = QString::fromLocal8Bit(TARGET_GSTREAMER_PLUGINS);

	if (!gstreamerPluginsPath.isEmpty()) {
		gstreamerPluginsPath = QDir::cleanPath(QString::fromLatin1("%1/../..%2")
							.arg(executable.absolutePath(), gstreamerPluginsPath));
	}
	qDebug() << "Looking for gstreamer in " << gstreamerPluginsPath;
#else
	qFatal("Please provide the unified directory containing the gstreamer plugins and gst-plugin-scanner.");
#endif

#if defined(QT_DEBUG)
	qputenv("GST_DEBUG", "ERROR:5,WARNING:5,INFO:5,DEBUG:5,LOG:5");
#endif
	qputenv("GST_PLUGIN_PATH_1_0", QByteArray());
	qputenv("GST_PLUGIN_SYSTEM_PATH_1_0", gstreamerPluginsPath.toLocal8Bit());
	qputenv("GST_PLUGIN_SCANNER_1_0", QString::fromLatin1("%1/gst-plugin-scanner").arg(gstreamerPluginsPath).toLocal8Bit());
#endif // APPIMAGE

	// register qMetaTypes
	qRegisterMetaType<ProviderListItem>();
	qRegisterMetaType<RosterItem>();
	qRegisterMetaType<RosterItemWatcher *>();
	qRegisterMetaType<RosterModel*>();
	qRegisterMetaType<RosterManager*>();
	qRegisterMetaType<Message>();
	qRegisterMetaType<MessageModel*>();
	qRegisterMetaType<MessageHandler*>();
	qRegisterMetaType<DiscoveryManager*>();
	qRegisterMetaType<VCardManager*>();
	qRegisterMetaType<VersionManager*>();
	qRegisterMetaType<RegistrationManager*>();
	qRegisterMetaType<FileSharingController *>();
	qRegisterMetaType<OmemoManager *>();
	qRegisterMetaType<AvatarFileStorage*>();
	qRegisterMetaType<QmlUtils*>();
	qRegisterMetaType<QVector<Message>>();
	qRegisterMetaType<QVector<RosterItem>>();
	qRegisterMetaType<QHash<QString,RosterItem>>();
	qRegisterMetaType<std::function<void()>>();
	qRegisterMetaType<std::function<void(RosterItem&)>>();
	qRegisterMetaType<std::function<void(Message&)>>();
	qRegisterMetaType<QXmppVCardIq>();
//	qRegisterMetaType<QMimeType>();
	qRegisterMetaType<CameraInfo>();
	qRegisterMetaType<AudioDeviceInfo>();
	qRegisterMetaType<MediaSettings>();
	qRegisterMetaType<ImageEncoderSettings>();
	qRegisterMetaType<AudioEncoderSettings>();
	qRegisterMetaType<VideoEncoderSettings>();
	qRegisterMetaType<CredentialsValidator*>();
	qRegisterMetaType<QXmppVersionIq>();
	qRegisterMetaType<QXmppUri>();
	qRegisterMetaType<QMap<QString, QUrl>>();

	// Enums for c++ member calls using enums
	qRegisterMetaType<Qt::ApplicationState>();
	qRegisterMetaType<QXmppClient::State>();
	qRegisterMetaType<QXmppMessage::State>();
	qRegisterMetaType<QXmppStanza::Error>();
    qRegisterMetaType<Enums>();
    qRegisterMetaType<Enums::MessageType>();
    qRegisterMetaType<Enums::ConnectionState>();
	qRegisterMetaType<PublicGroupChatModel::CustomRole>();
	qRegisterMetaType<ClientWorker::ConnectionError>();
	qRegisterMetaType<Presence::Availability>();
    qRegisterMetaType<Enums::DeliveryState>();
	qRegisterMetaType<MessageOrigin>();
	qRegisterMetaType<CommonEncoderSettings::EncodingQuality>();
	qRegisterMetaType<CommonEncoderSettings::EncodingMode>();
	qRegisterMetaType<AudioDeviceModel::Mode>();
	qRegisterMetaType<MediaRecorder::Type>();
	qRegisterMetaType<MediaRecorder::AvailabilityStatus>();
	qRegisterMetaType<MediaRecorder::State>();
	qRegisterMetaType<MediaRecorder::Status>();
	qRegisterMetaType<MediaRecorder::Error>();
	qRegisterMetaType<ProviderListModel::Role>();
	qRegisterMetaType<ChatState::State>();
	qRegisterMetaType<Encryption>();

	// QXmpp
	qRegisterMetaType<QXmppResultSetReply>();
	qRegisterMetaType<QXmppMessage>();
	qRegisterMetaType<QXmppPresence>();
	qRegisterMetaType<QXmppDiscoveryIq>();
	qRegisterMetaType<QHash<QString, QHash<QByteArray, QXmpp::TrustLevel>>>();

	// Qt-Translator
	QTranslator qtTranslator;
#if defined(SFOS)
    qtTranslator.load(SailfishApp::pathTo("translations").toLocalFile() + "/" + "qt_" + QLocale::system().name() + ".qm");
    pApp->installTranslator(&qtTranslator);
#else
	qtTranslator.load("qt_" + QLocale::system().name(),
	                  QLibraryInfo::location(QLibraryInfo::TranslationsPath));
	QCoreApplication::installTranslator(&qtTranslator);
#endif

	//
	// Command line arguments
	//

	// create parser and add a description
	QCommandLineParser parser;
	// parse the arguments
	QString commandLineErrorMessage;
	switch (parseCommandLine(parser, &commandLineErrorMessage)) {
	case CommandLineError:
		qWarning() << commandLineErrorMessage;
		return 1;
	case CommandLineVersionRequested:
		parser.showVersion();
		return 0;
	case CommandLineHelpRequested:
		parser.showHelp();
		return 0;
	case CommandLineOk:
		break;
	}

#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID) && !defined(SFOS) 
#ifdef NDEBUG
	if (app.isSecondary()) {
		qDebug() << "Another instance of" << APPLICATION_DISPLAY_NAME << "is already running!";
#else
	// check if another instance already runs
	if (app.isSecondary() && !parser.isSet("multiple")) {
		qDebug().noquote() << QString("Another instance of %1 is already running.")
		                      .arg(APPLICATION_DISPLAY_NAME)
		                   << "You can enable multiple instances by specifying '--multiple'.";
#endif

		// send a possible link to the primary instance
		if (const auto positionalArguments = parser.positionalArguments(); !positionalArguments.isEmpty())
			app.sendMessage(positionalArguments.first().toUtf8());
		return 0;
	}
#endif

	//
	// Kaidan back-end
	//
//    Kaidan kaidan(!parser.isSet("disable-xml-log"));
    Kaidan kaidan(true);

#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID) && !defined(SFOS) 
	// receive messages from other instances of Kaidan
	Kaidan::connect(&app, &SingleApplication::receivedMessage,
	                &kaidan, &Kaidan::receiveMessage);
#endif

#if !defined(SFOS)
	// open the XMPP-URI/link (if given)
	if (const auto positionalArguments = parser.positionalArguments(); !positionalArguments.isEmpty())
		kaidan.addOpenUri(positionalArguments.first());

	//
	// QML-GUI
	//
	if (QIcon::themeName().isEmpty()) {
		QIcon::setThemeName("breeze");
	}
    QQmlApplicationEngine engine;

	engine.addImageProvider(QLatin1String(BITS_OF_BINARY_IMAGE_PROVIDER_NAME), BitsOfBinaryImageProvider::instance());

    // QtQuickControls2 Style
	if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
		const QString defaultStyle = QStringLiteral("Material");
#else
		const QString defaultStyle = QStringLiteral("org.kde.desktop");
#endif
		qDebug() << "QT_QUICK_CONTROLS_STYLE not set, setting to" << defaultStyle;
		qputenv("QT_QUICK_CONTROLS_STYLE", defaultStyle.toLatin1());
	}

#if defined(Q_OS_WIN) || defined(Q_OS_MACOS)
	QApplication::setStyle(QStringLiteral("breeze"));
#endif
#endif

	// QML type bindings
#ifdef STATIC_BUILD
	KirigamiPlugin::getInstance().registerTypes();
#endif

#if defined(SFOS)
    qmlRegisterType<ImagePainter>("im.kaidan.kaidan", 0, 1, "ImagePainter");
#endif
	qmlRegisterType<StatusBar>("StatusBar", 0, 1, "StatusBar");
	qmlRegisterType<EmojiModel>("EmojiModel", 0, 1, "EmojiModel");
	qmlRegisterType<EmojiProxyModel>("EmojiModel", 0, 1, "EmojiProxyModel");
    qmlRegisterType<QrCodeScannerFilter>("im.kaidan.kaidan", 1, 0, "QrCodeScannerFilter");
    qmlRegisterType<VCardModel>("im.kaidan.kaidan", 1, 0, "VCardModel");
    qmlRegisterType<RosterFilterProxyModel>("im.kaidan.kaidan", 1, 0, "RosterFilterProxyModel");
    qmlRegisterType<MessageComposition>("im.kaidan.kaidan", 1, 0, "MessageComposition");
    qmlRegisterType<FileSelectionModel>("im.kaidan.kaidan", 1, 0, "FileSelectionModel");
    qmlRegisterType<CameraModel>("im.kaidan.kaidan", 1, 0, "CameraModel");
    qmlRegisterType<AudioDeviceModel>("im.kaidan.kaidan", 1, 0, "AudioDeviceModel");
    qmlRegisterType<MediaSettingsContainerModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsContainerModel");
    qmlRegisterType<MediaSettingsResolutionModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsResolutionModel");
    qmlRegisterType<MediaSettingsQualityModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsQualityModel");
    qmlRegisterType<MediaSettingsImageCodecModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsImageCodecModel");
    qmlRegisterType<MediaSettingsAudioCodecModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsAudioCodecModel");
    qmlRegisterType<MediaSettingsAudioSampleRateModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsAudioSampleRateModel");
    qmlRegisterType<MediaSettingsVideoCodecModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsVideoCodecModel");
    qmlRegisterType<MediaSettingsVideoFrameRateModel>("im.kaidan.kaidan", 1, 0, "MediaSettingsVideoFrameRateModel");
    qmlRegisterType<MediaRecorder>("im.kaidan.kaidan", 1, 0, "MediaRecorder");
    qmlRegisterType<UserDevicesModel>("im.kaidan.kaidan", 1, 0, "UserDevicesModel");
    qmlRegisterType<CredentialsGenerator>("im.kaidan.kaidan", 1, 0, "CredentialsGenerator");
    qmlRegisterType<CredentialsValidator>("im.kaidan.kaidan", 1, 0, "CredentialsValidator");
    qmlRegisterType<QrCodeGenerator>("im.kaidan.kaidan", 1, 0, "QrCodeGenerator");
    qmlRegisterType<RegistrationDataFormFilterModel>("im.kaidan.kaidan", 1, 0, "RegistrationDataFormFilterModel");
    qmlRegisterType<ProviderListModel>("im.kaidan.kaidan", 1, 0, "ProviderListModel");
    qmlRegisterType<FileProgressWatcher>("im.kaidan.kaidan", 1, 0, "FileProgressWatcher");
    qmlRegisterType<UserPresenceWatcher>("im.kaidan.kaidan", 1, 0, "UserPresenceWatcher");
    qmlRegisterType<UserResourcesWatcher>("im.kaidan.kaidan", 1, 0, "UserResourcesWatcher");
    qmlRegisterType<RosterItemWatcher>("im.kaidan.kaidan", 1, 0, "RosterItemWatcher");
    qmlRegisterType<RecentPicturesModel>("im.kaidan.kaidan", 1, 0, "RecentPicturesModel");
    qmlRegisterType<NotificationsMutedWatcher>("im.kaidan.kaidan", 1, 0, "NotificationsMutedWatcher");
	qmlRegisterType<PublicGroupChatSearchManager>("PublicGroupChats", 1, 0, "SearchManager");
	qmlRegisterType<PublicGroupChatModel>("PublicGroupChats", 1, 0, "Model");
	qmlRegisterType<PublicGroupChatProxyModel>("PublicGroupChats", 1, 0, "ProxyModel");
    qmlRegisterType<OmemoWatcher>("im.kaidan.kaidan", 1, 0, "OmemoWatcher");
    qmlRegisterType<HostCompletionModel>("im.kaidan.kaidan", 1, 0, "HostCompletionModel");
    qmlRegisterType<HostCompletionProxyModel>("im.kaidan.kaidan", 1, 0, "HostCompletionProxyModel");

	qmlRegisterUncreatableType<QAbstractItemModel>("EmojiModel", 0, 1, "QAbstractItemModel", "Used by proxy models");
	qmlRegisterUncreatableType<Emoji>("EmojiModel", 0, 1, "Emoji", "Used by emoji models");
//	qmlRegisterUncreatableType<QMimeType>("im.kaidan.kaidan", 1, 0, "QMimeType", "QMimeType type usable");
    qmlRegisterUncreatableType<CameraInfo>("im.kaidan.kaidan", 1, 0, "CameraInfo", "CameraInfo type usable");
    qmlRegisterUncreatableType<AudioDeviceInfo>("im.kaidan.kaidan", 1, 0, "AudioDeviceInfo", "AudioDeviceInfo type usable");
    qmlRegisterUncreatableType<MediaSettings>("im.kaidan.kaidan", 1, 0, "MediaSettings", "MediaSettings type usable");
    qmlRegisterUncreatableType<CommonEncoderSettings>("im.kaidan.kaidan", 1, 0, "CommonEncoderSettings", "CommonEncoderSettings type usable");
    qmlRegisterUncreatableType<ImageEncoderSettings>("im.kaidan.kaidan", 1, 0, "ImageEncoderSettings", "ImageEncoderSettings type usable");
    qmlRegisterUncreatableType<AudioEncoderSettings>("im.kaidan.kaidan", 1, 0, "AudioEncoderSettings", "AudioEncoderSettings type usable");
    qmlRegisterUncreatableType<VideoEncoderSettings>("im.kaidan.kaidan", 1, 0, "VideoEncoderSettings", "VideoEncoderSettings type usable");
    qmlRegisterUncreatableType<ClientWorker>("im.kaidan.kaidan", 1, 0, "ClientWorker", "Cannot create object; only enums defined!");
    qmlRegisterUncreatableType<DataFormModel>("im.kaidan.kaidan", 1, 0, "DataFormModel", "Cannot create object; only enums defined!");
    qmlRegisterUncreatableType<Presence>("im.kaidan.kaidan", 1, 0, "Presence", "Cannot create object; only enums defined!");
    qmlRegisterUncreatableType<RegistrationManager>("im.kaidan.kaidan", 1, 0, "RegistrationManager", "Cannot create object; only enums defined!");
    qmlRegisterUncreatableType<ChatState>("im.kaidan.kaidan", 1, 0, "ChatState", "Cannot create object; only enums defined");
#if !defined(SFOS)
    qmlRegisterUncreatableType<RosterModel>("im.kaidan.kaidan", 1, 0, "RosterModel", "Cannot create object; only enums defined!");
#endif
    qmlRegisterUncreatableType<ServerFeaturesCache>("im.kaidan.kaidan", 1, 0, "ServerFeaturesCache", "ServerFeaturesCache type usable");
    qmlRegisterUncreatableType<Encryption>("im.kaidan.kaidan", 1, 0, "Encryption", "Cannot create object; only enums defined!");
    qmlRegisterUncreatableType<File>("im.kaidan.kaidan", 1, 0, "File", "Not creatable from QML");
	qmlRegisterUncreatableType<PublicGroupChat>("PublicGroupChats", 1, 0, "PublicGroupChat", "Used by PublicGroupChatModel");
#if !defined(SFOS)
    qmlRegisterUncreatableType<HostCompletionModel>("im.kaidan.kaidan", 1, 0, "HostCompletionModel", "Cannot create object; only enums defined!");
#endif
#if defined(SFOS)
    qmlRegisterUncreatableType<ChatState>("im.kaidan.kaidan", 1, 0, "ChatState", "Can't create object; only enums defined!");
    qmlRegisterUncreatableType<Enums>("im.kaidan.kaidan", 1, 0, "Enums", "Can't create object; only enums defined!");
#else
    qmlRegisterUncreatableMetaObject(ChatState::staticMetaObject, "im.kaidan.kaidan", 1, 0, "ChatState", "Can't create object; only enums defined!");
#endif

	qmlRegisterSingletonType<MediaUtils>("MediaUtils", 0, 1, "MediaUtilsInstance", [](QQmlEngine *, QJSEngine *) {
		QObject *instance = new MediaUtils(qApp);
		return instance;
	});
    qmlRegisterSingletonType<QmlUtils>("im.kaidan.kaidan", 1, 0, "Utils", [](QQmlEngine *, QJSEngine *) {
		return static_cast<QObject*>(QmlUtils::instance());
	});
    qmlRegisterSingletonType<Kaidan>("im.kaidan.kaidan", 1, 0, "Kaidan", [](QQmlEngine *engine, QJSEngine *) {
		engine->setObjectOwnership(Kaidan::instance(), QQmlEngine::CppOwnership);
		return static_cast<QObject *>(Kaidan::instance());
	});
    qmlRegisterSingletonType<GuiStyle>("im.kaidan.kaidan", 1, 0, "Style", [](QQmlEngine *, QJSEngine *) {
		return static_cast<QObject *>(new GuiStyle(QCoreApplication::instance()));
	});
    qmlRegisterSingletonType<AccountManager>("im.kaidan.kaidan", 1, 0, "AccountManager", [](QQmlEngine *, QJSEngine *) {
		return static_cast<QObject *>(AccountManager::instance());
	});
    qmlRegisterSingletonType<RosterModel>("im.kaidan.kaidan", 1, 0, "RosterModel", [](QQmlEngine *, QJSEngine *) {
		return static_cast<QObject *>(RosterModel::instance());
	});
    qmlRegisterSingletonType<MessageModel>("im.kaidan.kaidan", 1, 0, "MessageModel", [](QQmlEngine *, QJSEngine *) {
		return static_cast<QObject *>(MessageModel::instance());
	});
    qmlRegisterSingletonType<HostCompletionModel>("im.kaidan.kaidan", 1, 0, "HostCompletionModel", [](QQmlEngine *, QJSEngine *) {
		static auto self = new HostCompletionModel(qApp);
		return static_cast<QObject *>(self);
	});

#if defined(SFOS)
    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->showFullScreen();

#else
    engine.load(QUrl("qrc:/qml/main.qml"));
	if (engine.rootObjects().isEmpty())
		return -1;
#endif
#ifdef Q_OS_ANDROID
	QtAndroid::hideSplashScreen();
#endif

#ifndef SFOS
	// enter qt main loop
	return app.exec();
#else
    qDebug() << "starting...";
	return pApp->exec();
#endif
}
