%global app_id io.github.jmuelbert.qtwidgettest

Name:       qtwidgettest
Version:    0.0.1
Release:    1%{!?suse_version:%{?dist}}
Summary:    Remote GUI for transmission-daemon
%if %{defined suse_version}
Group:      Develop/Other
License:   EUPL-1.2
%else
License:    EUPL-1.2
%endif
URL:        https://github.com/jmuelbert/qt_conan_boilerplate_template

Source0:    https://github.com//jmuelbert/qt_conan_boilerplate_template/archive/%{version}.tar.gz

Requires:      hicolor-icon-theme
BuildRequires: cmake
BuildRequires: desktop-file-utils
BuildRequires: gettext
BuildRequires: make
BuildRequires: cmake(Qt5)
BuildRequires: cmake(Qt5Concurrent)
BuildRequires: cmake(Qt5Core)
BuildRequires: cmake(Qt5DBus)
BuildRequires: cmake(Qt5LinguistTools)
BuildRequires: cmake(Qt5Network)
BuildRequires: cmake(Qt5Test)
BuildRequires: cmake(Qt5Widgets)
BuildRequires: cmake(Qt5X11Extras)
BuildRequires: cmake(fmt)
BuildRequires: cmake(spdlog)
BuildRequires: cmake(KF5WidgetsAddons)
BuildRequires: cmake(KF5WindowSystem)

%if %{defined suse_version}
BuildRequires: appstream-glib
# OBS complains about not owned directories if hicolor-icon-theme isn't installed at build time
BuildRequires: hicolor-icon-theme
%else
    %if %{defined mageia}
BuildRequires: appstream-util
    %else
BuildRequires: libappstream-glib
    %endif
%endif

%if %{defined fedora} && "%{toolchain}" == "clang"
BuildRequires: clang
%else
    %if %{defined suse_version} && 0%{?suse_version} == 1500
        %global leap_gcc_version 11
BuildRequires: gcc%{leap_gcc_version}-c++
    %else
BuildRequires: gcc-c++
    %endif
%endif

%if %{defined suse_version}
    %global _metainfodir %{_datadir}/metainfo
%endif

%description
Remote GUI for Transmission BitTorrent client.


%prep
%autosetup -n tremotesf2-%{version}


%build
%if %{defined suse_version} && 0%{?suse_version} == 1500
    export CXX=g++-%{leap_gcc_version}
%endif
%cmake
%cmake_build

%check
%ctest

%install
%cmake_install
appstream-util validate-relax --nonet %{buildroot}/%{_metainfodir}/%{app_id}.appdata.xml
desktop-file-validate %{buildroot}/%{_datadir}/applications/%{app_id}.desktop

%files
%{_bindir}/%{name}
%{_datadir}/icons/hicolor/*/apps/%{app_id}.*
%{_datadir}/applications/%{app_id}.desktop
%{_metainfodir}/%{app_id}.appdata.xml

%changelog
* Sat Sep 03 2022 Jürgen Mülbert <juergen.muelbert@gmail.com> - 0.0.1-1
-  qtwidgettest 0.0.1
