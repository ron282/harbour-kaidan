Name:	    harbour-kaidan
Summary:    QXmpp Client Application
Version:    0.0.1
Release:    1%{?dist}
Group:      Qt/Qt
Source:     master.zip
URL:        https://github.com/ron282/kaidan.git
License:    MIT
BuildRequires:	pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Location)
BuildRequires:  pkgconfig(Qt5Positioning)
BuildRequires:  libiphb-devel
BuildRequires:  libxml2-devel
BuildRequires:  openssl-devel
BuildRequires:  libgpg-error-devel
BuildRequires:  libgcrypt-devel
BuildRequires:  sqlite-devel
BuildRequires:  QXmpp-devel
BuildRequires:  ZXing-devel
BuildRequires:  ecm-devel
Requires:       QXmpp
Requires:       qt5-qtdeclarative-import-positioning
Requires:       qt5-qtdeclarative-import-location

%description
XMPP Client for Sailfish OS


%prep
%setup -q


%build
qmake CONFIG+=sailfishapp CONFIG+=sailfishapp_i18n DEFINES+=SFOS
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
# >> install pre
# << install pre
install -d %{buildroot}%{_bindir}
install -p -m 0755 %(pwd)/%{name} %{buildroot}%{_bindir}/%{name}
install -d %{buildroot}%{_datadir}/applications
install -d %{buildroot}%{_datadir}/lipstick/notificationcategories
install -d %{buildroot}%{_datadir}/%{name}
install -d %{buildroot}%{_datadir}/%{name}/qml
install -d %{buildroot}%{_datadir}/%{name}/icons
install -d %{buildroot}%{_datadir}/%{name}/images
install -d %{buildroot}%{_datadir}/%{name}/translations
install -d %{buildroot}%{_datadir}/icons/hicolor/86x86/apps
cp -Ra %{_sourcedir}/../src/qml/* %{buildroot}%{_datadir}/%{name}/qml
cp -Ra %{_sourcedir}/../data/images/*.svg %{buildroot}%{_datadir}/%{name}/images
install -p %{_sourcedir}/../src/qml/%{name}.desktop %{buildroot}%{_datadir}/applications/%{name}.desktop
install -m 0444 -t %{buildroot}%{_datadir}/icons/hicolor/86x86/apps/ %{_sourcedir}/../resources/icons/86x86/%{name}.png
install -p %{_sourcedir}/../resources/%{name}-message.conf %{buildroot}%{_datadir}/lipstick/notificationcategories/%{name}-message.conf


strip %{buildroot}%{_bindir}/%{name}

# >> install post
# << install post

desktop-file-install --delete-original \
    --dir %{buildroot}%{_datadir}/applications \
    %{buildroot}%{_datadir}/applications/*.desktop

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_datadir}/applications/%{name}.desktop
%{_datadir}/lipstick/notificationcategories/%{name}-message.conf
%{_datadir}/%{name}/qml
%{_datadir}/%{name}/images
%{_datadir}/%{name}/icons
%{_datadir}/%{name}/translations
%{_datadir}/icons/hicolor/86x86/apps
%{_bindir}/%{name}
# >> files
# << files


%changelog

