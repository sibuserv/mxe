# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtbase
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.14.0
$(PKG)_CHECKSUM := 4ef921c0f208a1624439801da8b3f4344a3793b660ce1095f2b7f5c4246b9463
$(PKG)_SUBDIR   := $(PKG)-everywhere-src-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.qt.io/official_releases/qt/5.14/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := cc fontconfig freetype harfbuzz jpeg libpng openssl sqlite zlib
$(PKG)_DEPS_$(BUILD) :=
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

define $(PKG)_UPDATE
    $(WGET) -q -O- https://download.qt.io/official_releases/qt/5.8/ | \
    $(SED) -n 's,.*href="\(5\.[0-9]\.[^/]*\)/".*,\1,p' | \
    grep -iv -- '-rc' | \
    sort |
    tail -1
endef

define $(PKG)_BUILD
    # ICU is buggy. See #653. TODO: reenable it some time in the future.
    cd '$(1)' && \
        CFLAGS="$(CFLAGS)" \
        CXXFLAGS="$(CXXFLAGS)" \
        LDFLAGS="$(LDFLAGS)" \
        OPENSSL_LIBS="`'$(TARGET)-pkg-config' --libs-only-l openssl`" \
        PKG_CONFIG="${TARGET}-pkg-config" \
        PKG_CONFIG_SYSROOT_DIR="/" \
        PKG_CONFIG_LIBDIR="$(PREFIX)/$(TARGET)/lib/pkgconfig" \
        MAKE=$(MAKE) \
        ./configure \
            -opensource \
            -confirm-license \
            -xplatform win32-g++ \
            -device-option CROSS_COMPILE=${TARGET}- \
            -device-option PKG_CONFIG='${TARGET}-pkg-config' \
            -pkg-config \
            -force-pkg-config \
            -no-use-gold-linker \
            -release \
            $(if $(BUILD_STATIC), -static,)$(if $(BUILD_SHARED), -shared,) \
            -prefix '$(PREFIX)/$(TARGET)/qt5' \
            -no-icu \
            -opengl desktop \
            -no-glib \
            -accessibility \
            -nomake examples \
            -nomake tests \
            -plugin-sql-sqlite \
            -system-zlib \
            -system-libpng \
            -system-libjpeg \
            -system-sqlite \
            -fontconfig \
            -system-freetype \
            -system-harfbuzz \
            -openssl-linked \
            -no-sql-sqlite2 \
            -no-sql-mysql \
            -no-sql-psql \
            -no-sql-odbc \
            -no-sql-tds \
            -no-sql-oci \
            -no-sql-db2 \
            -no-sql-ibase \
            -no-pch \
            -v \
            $($(PKG)_CONFIGURE_OPTS)

    $(MAKE) -C '$(1)' -j '$(JOBS)'
    rm -rf '$(PREFIX)/$(TARGET)/qt5'
    $(MAKE) -C '$(1)' -j 1 install
    ln -sf '$(PREFIX)/$(TARGET)/qt5/bin/qmake' '$(PREFIX)/bin/$(TARGET)'-qmake-qt5

    mkdir            '$(1)/test-qt'
    cd               '$(1)/test-qt' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake' '$(PWD)/src/qt-test.pro'
    $(MAKE)       -C '$(1)/test-qt' -j '$(JOBS)'
    $(INSTALL) -m755 '$(1)/test-qt/test-qt5.exe' '$(PREFIX)/$(TARGET)/bin/'

    # build test the manual way
    mkdir '$(1)/test-$(PKG)-pkgconfig'
    '$(PREFIX)/$(TARGET)/qt5/bin/uic' -o '$(1)/test-$(PKG)-pkgconfig/ui_qt-test.h' '$(TOP_DIR)/src/qt-test.ui'
    '$(PREFIX)/$(TARGET)/qt5/bin/moc' \
        -o '$(1)/test-$(PKG)-pkgconfig/moc_qt-test.cpp' \
        -I'$(1)/test-$(PKG)-pkgconfig' \
        '$(TOP_DIR)/src/qt-test.hpp'
    '$(PREFIX)/$(TARGET)/qt5/bin/rcc' -name qt-test -o '$(1)/test-$(PKG)-pkgconfig/qrc_qt-test.cpp' '$(TOP_DIR)/src/qt-test.qrc'
    '$(TARGET)-g++' \
        -W -Wall -std=c++0x -pedantic \
        '$(TOP_DIR)/src/qt-test.cpp' \
        '$(1)/test-$(PKG)-pkgconfig/moc_qt-test.cpp' \
        '$(1)/test-$(PKG)-pkgconfig/qrc_qt-test.cpp' \
        -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG)-pkgconfig.exe' \
        -I'$(1)/test-$(PKG)-pkgconfig' \
        `'$(TARGET)-pkg-config' Qt5Widgets$(BUILD_TYPE_SUFFIX) --cflags --libs`

    # setup cmake toolchain
    echo 'set(CMAKE_SYSTEM_PREFIX_PATH "$(PREFIX)/$(TARGET)/qt5" ${CMAKE_SYSTEM_PREFIX_PATH})' > '$(CMAKE_TOOLCHAIN_DIR)/$(PKG).cmake'

    # batch file to run test programs
    (printf 'set PATH=..\\lib;..\\qt5\\bin;..\\qt5\\lib;%%PATH%%\r\n'; \
     printf 'set QT_QPA_PLATFORM_PLUGIN_PATH=..\\qt5\\plugins\r\n'; \
     printf 'test-qt5.exe\r\n'; \
     printf 'test-qtbase-pkgconfig.exe\r\n';) \
     > '$(PREFIX)/$(TARGET)/bin/test-qt5.bat'

    # add libs to CMake config of Qt5Core to fix static linking
    $(if $(BUILD_STATIC), \
        $(SED) -i 's^set(_Qt5Core_LIB_DEPENDENCIES \"\")^set(_Qt5Core_LIB_DEPENDENCIES \"ole32;uuid;ws2_32;advapi32;shell32;user32;kernel32;mpr;version;winmm;z;netapi32;userenv\")^g' '$(PREFIX)/$(TARGET)/qt5/lib/cmake/Qt5Core/Qt5CoreConfig.cmake' && \
        $(SED) -i 's^set(_Qt5Gui_LIB_DEPENDENCIES \"Qt5::Core\")^set(_Qt5Gui_LIB_DEPENDENCIES \"Qt5::Core;dwmapi;winspool;wtsapi32;jasper;mng;tiff;webpdemux;webpmux;d3d11;dxgi;dxguid;harfbuzz;cairo;gobject-2.0;fontconfig;freetype;usp10;msimg32;pixman-1;ffi;expat;bz2;png16;harfbuzz_too;freetype_too;glib-2.0;shlwapi;pcre;intl;iconv;gdi32;comdlg32;oleaut32;imm32;opengl32;mpr;userenv;version;netapi32;ws2_32;advapi32;kernel32;ole32;shell32;uuid;user32;winmm;lcms2;pthread;webp;lzma;jpeg;z;m\")^g' '$(PREFIX)/$(TARGET)/qt5/lib/cmake/Qt5Gui/Qt5GuiConfig.cmake' && \
        $(SED) -i 's^set(_Qt5Network_LIB_DEPENDENCIES \"Qt5::Core\")^set(_Qt5Network_LIB_DEPENDENCIES \"Qt5::Core;ssl;crypto;ws2_32;gdi32;crypt32;iphlpapi\")^g' '$(PREFIX)/$(TARGET)/qt5/lib/cmake/Qt5Network/Qt5NetworkConfig.cmake' && \
        $(SED) -i 's^set(_Qt5Widgets_LIB_DEPENDENCIES \"Qt5::Gui;Qt5::Core\")^set(_Qt5Widgets_LIB_DEPENDENCIES \"Qt5::Gui;Qt5::Core;gdi32;comdlg32;oleaut32;imm32;opengl32;png16;harfbuzz;ole32;uuid;ws2_32;advapi32;shell32;user32;kernel32;mpr;version;winmm;z;shell32;uxtheme;dwmapi\")^g' '$(PREFIX)/$(TARGET)/qt5/lib/cmake/Qt5Widgets/Qt5WidgetsConfig.cmake',
    )
endef

define $(PKG)_BUILD_$(BUILD)
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        -prefix '$(PREFIX)/$(TARGET)/qt5' \
        -static \
        -release \
        -opensource \
        -confirm-license \
        -no-dbus \
        -no-{eventfd,glib,icu,openssl} \
        -no-sql-{db2,ibase,mysql,oci,odbc,psql,sqlite,sqlite2,tds} \
        -no-use-gold-linker \
        -nomake examples \
        -nomake tests \
        -make tools \
        -continue \
        -verbose
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    rm -rf '$(PREFIX)/$(TARGET)/qt5'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
    ln -sf '$(PREFIX)/$(TARGET)/qt5/bin/qmake' '$(PREFIX)/bin/$(TARGET)'-qmake-qt5
endef
