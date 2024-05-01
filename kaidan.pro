TARGET = harbour-kaidan

TEMPLATE = app
QT += qml quick core sql xml concurrent multimedia positioning widgets multimedia-private location


LBUILD = build

DEFINES += WITH_OMEMO_V03

contains(DEFINES, DBUS) {
    CONFIG += console
    QT += dbus
}

INCLUDEPATH += /usr/include/QXmppQt5
INCLUDEPATH += /usr/include/QXmppQt5/Omemo
INCLUDEPATH += /usr/include/QXmppQt5/base
INCLUDEPATH += /usr/include/QXmppQt5/client

INCLUDEPATH += source

! contains(DEFINES, SFOS) {
    QMAKE_CXXFLAGS += -Wno-deprecated-this-capture -Wno-deprecated-declarations -Wno-placement-new -Wno-parentheses -Wno-unused-but-set-parameter
}

contains(DEFINES, QMLLIVE_SOURCE) {
    QMLLIVEPROJECT = $$_PRO_FILE_PWD_/../qmllive
    include($${QMLLIVEPROJECT}/src/src.pri)
}

contains(DEFINES, SFOS) {
    QMAKE_CXXFLAGS += -Wno-deprecated-declarations -Wno-placement-new -Wno-parentheses -Wno-unused-but-set-parameter
    LIBS += -liphb
}

QMAKE_CXXFLAGS += -std=c++17
LIBS += -lgcrypt -lZXing -lQXmppQt5 -lQXmppOmemoQt5

CONFIG += QXmpp-devel ZXing

DEFINES += BOOST_SIGNALS_NO_DEPRECATION_WARNING



DEFINES += APPLICATION_ID=\\\"im.kaidan.kaidan\\\"
DEFINES += APPLICATION_DISPLAY_NAME=\\\"SailKaidan\\\"
DEFINES += APPLICATION_NAME=\\\"harbour-kaidan\\\"
DEFINES += APPLICATION_DESCRIPTION=\\\"XmppClient\\\"
DEFINES += VERSION_MAJOR=0
DEFINES += VERSION_MINOR=10
DEFINES += VERSION_PATCH=0
DEFINES += VERSION_STRING=\\\"0.10.0\\\"
DEFINES += QSTRINGVIEW_EMULATE
DEFINES += Q_COMPILER_UNICODE_STRINGS

SOURCES += \
    3rdparty/QImagePainter/qimagepainter.cpp \
    src/Account.cpp \
    src/AccountDb.cpp \
    src/AccountManager.cpp \
    src/AtmManager.cpp \
    src/AudioDeviceModel.cpp \
    src/AvatarFileStorage.cpp \
    src/BitsOfBinaryImageProvider.cpp \
    src/Blocking.cpp \
    src/CameraImageCapture.cpp \
    src/CameraModel.cpp \
    src/ChatHintModel.cpp \
    src/ClientWorker.cpp \
    src/CredentialsGenerator.cpp \
    src/CredentialsValidator.cpp \
    src/Database.cpp \
    src/DatabaseComponent.cpp \
    src/DataFormModel.cpp \
    src/DiscoveryManager.cpp \
    src/EmojiModel.cpp \
    src/FileModel.cpp \
    src/FileProgressCache.cpp \
    src/FileProxyModel.cpp \
    src/FileSharingController.cpp \
    src/HostCompletionProxyModel.cpp \
    src/HostCompletionModel.cpp \
    src/Kaidan.cpp \
    src/LogHandler.cpp \
    src/main.cpp \
    src/MediaRecorder.cpp \
    src/MediaSettings.cpp \
    src/MediaUtils.cpp \
    src/Message.cpp \
    src/MessageComposition.cpp \
    src/MessageDb.cpp \
    src/MessageHandler.cpp \
    src/MessageModel.cpp \
    src/Notifications.cpp \
    src/OmemoCache.cpp \
    src/OmemoDb.cpp \
    src/OmemoManager.cpp \
    src/OmemoModel.cpp \
    src/OmemoWatcher.cpp \
    src/PresenceCache.cpp \
    src/ProviderListItem.cpp \
    src/ProviderListModel.cpp \
    src/PublicGroupChat.cpp \
    src/PublicGroupChatModel.cpp \
    src/PublicGroupChatProxyModel.cpp \
    src/PublicGroupChatSearchManager.cpp \
    src/QmlUtils.cpp \
    src/QrCodeDecoder.cpp \
    src/QrCodeGenerator.cpp \
    src/QrCodeScannerFilter.cpp \
    src/QrCodeVideoFrame.cpp \
    src/RecentPicturesModel.cpp \
    src/RegistrationDataFormFilterModel.cpp \
    src/RegistrationDataFormModel.cpp \
    src/RegistrationManager.cpp \
    src/RosterDb.cpp \
    src/RosterFilterProxyModel.cpp \
    src/RosterItem.cpp \
    src/RosterItemWatcher.cpp \
    src/RosterManager.cpp \
    src/RosterModel.cpp \
    src/ServerFeaturesCache.cpp \
    src/Settings.cpp \
    src/SqlUtils.cpp \
    src/StatusBar.cpp \
    src/TrustDb.cpp \
    src/UserDevicesModel.cpp \
    src/VCardCache.cpp \
    src/VCardManager.cpp \
    src/VCardModel.cpp \
    src/VersionManager.cpp \
    src/qxmpp-exts/QXmppColorGenerator.cpp \
    src/qxmpp-exts/QXmppUri.cpp \
    src/hsluv-c/hsluv.c


HEADERS += \
    3rdparty/QImagePainter/qimagepainter.h \
    src/Account.h \
    src/AccountDb.h \
    src/AbstractNotifier.h \
    src/AccountManager.h \
    src/Algorithms.h \
    src/AtmManager.h \
    src/AudioDeviceModel.h \
    src/AvatarFileStorage.h \
    src/BitsOfBinaryImageProvider.h \
    src/Blocking.h \
    src/CameraImageCapture.h \
    src/CameraModel.h \
    src/ChatHintModel.h \
    src/ClientWorker.h \
    src/CredentialsGenerator.h \
    src/CredentialsValidator.h \
    src/DatabaseComponent.h \
    src/Database.h \
    src/DataFormModel.h \
    src/DiscoveryManager.h \
    src/EmojiModel.h \
    src/Encryption.h \
    src/Enums.h \
    src/FileModel.h \
    src/FileProgressCache.h \
    src/FileProxyModel.h \
    src/FileSharingController.h \
    src/FutureUtils.h \
    src/Globals.h \
    src/GuiStyle.h \
    src/HostCompletionModel.h \
    src/HostCompletionProxyModel.h \
    src/JsonUtils.h \
    src/Kaidan.h \
    src/LogHandler.h \
    src/MediaRecorder.h \
    src/MediaSettingModel.h \
    src/MediaSettings.h \
    src/MediaUtils.h \
    src/MessageComposition.h \
    src/MessageDb.h \
    src/Message.h \
    src/MessageHandler.h \
    src/MessageModel.h \
    src/Notifications.h \
    src/OmemoCache.h \
    src/OmemoDb.h \
    src/OmemoManager.h \
    src/OmemoModel.h \
    src/OmemoWatcher.h \
    src/PresenceCache.h \
    src/ProviderListItem.h \
    src/ProviderListModel.h \
    src/PublicGroupChat.h \
    src/PublicGroupChatModel.h \
    src/PublicGroupChatProxyModel.h \
    src/PublicGroupChatSearchManager.h \
    src/QmlUtils.h \
    src/QrCodeDecoder.h \
    src/QrCodeGenerator.h \
    src/QrCodeScannerFilter.h \
    src/QrCodeVideoFrame.h \
    src/RecentPicturesModel.h \
    src/RegistrationDataFormFilterModel.h \
    src/RegistrationDataFormModel.h \
    src/RegistrationManager.h \
    src/RosterDb.h \
    src/RosterFilterProxyModel.h \
    src/RosterItem.h \
    src/RosterItemWatcher.h \
    src/RosterManager.h \
    src/RosterModel.h \
    src/ServerFeaturesCache.h \
    src/Settings.h \
    src/SqlUtils.h \
    src/static_plugins.h \
    src/StatusBar.h \
    src/TrustDb.h \
    src/UserDevicesModel.h \
    src/VCardCache.h \
    src/VCardManager.h \
    src/VCardModel.h \
    src/VersionManager.h 

HEADERS += \
    src/qxmpp-exts/QXmppColorGenerator.h \
    src/qxmpp-exts/QXmppUri.h \
    src/hsluv-c/hsluv.h \
    3rdparty/QEmuStringView/qemustringview.h \
    3rdparty/QtCore/QRandomGenerator.h \
    3rdparty/QtMultimedia/QVideoFrameToQImage.h 


lupdate_only {
        SOURCES += src/qml/*.qml \
           src/qml/details/*.qml \
           src/qml/elements/*.qml \
           src/qml/elements/fields/*.qml \
           src/qml/registration/*.qml \
           src/qml/settings/*.qml 
}

RESOURCES += \
  src/qml/qml.qrc \
  data/images/images.qrc \
  data/data.qrc \
  misc/misc.qrc

DISTFILES += \
    src/qml/harbour-kaidan.desktop


