# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtbase
$(PKG)_WEBSITE  := http://qt-project.org/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.8.0
$(PKG)_CHECKSUM := c17111ae02a44dc7be1ec2cf979a47ee9e58edf4904041a525c21f4fa53fc005
$(PKG)_SUBDIR   := $(PKG)-opensource-src-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-opensource-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://download.qt.io/official_releases/qt/5.8/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc fontconfig freetype jpeg libpng openssl zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- http://download.qt-project.org/official_releases/qt/5.8/ | \
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
        PKG_CONFIG_LIBDIR="$(PREFIX)/$(TARGET)/lib/pc" \
        ./configure \
            -opensource \
            -c++std c++11 \
            -confirm-license \
            -xplatform win32-g++ \
            -device-option CROSS_COMPILE=${TARGET}- \
            -device-option PKG_CONFIG='${TARGET}-pkg-config' \
            -pkg-config \
            -force-pkg-config \
            -no-use-gold-linker \
            -release \
            -static \
            -prefix '$(PREFIX)/$(TARGET)/qt5' \
            -no-icu \
            -opengl desktop \
            -no-glib \
            -accessibility \
            -nomake examples \
            -nomake tests \
            -system-zlib \
            -system-libpng \
            -system-libjpeg \
            -fontconfig \
            -system-freetype \
            -no-harfbuzz \
            -openssl-linked \
            -no-sql-sqlite \
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
    $(MAKE)       -C '$(1)/test-qt' -j '$(JOBS)' $(BUILD_TYPE)
    $(INSTALL) -m755 '$(1)/test-qt/$(BUILD_TYPE)/test-qt5.exe' '$(PREFIX)/$(TARGET)/bin/'

    # build test the manual way
    mkdir '$(1)/test-$(PKG)-pkgconfig'
    '$(PREFIX)/$(TARGET)/qt5/bin/uic' -o '$(1)/test-$(PKG)-pkgconfig/ui_qt-test.h' '$(TOP_DIR)/src/qt-test.ui'
    '$(PREFIX)/$(TARGET)/qt5/bin/moc' \
        -o '$(1)/test-$(PKG)-pkgconfig/moc_qt-test.cpp' \
        -I'$(1)/test-$(PKG)-pkgconfig' \
        '$(TOP_DIR)/src/qt-test.hpp'
    '$(PREFIX)/$(TARGET)/qt5/bin/rcc' -name qt-test -o '$(1)/test-$(PKG)-pkgconfig/qrc_qt-test.cpp' '$(TOP_DIR)/src/qt-test.qrc'
    '$(TARGET)-g++' \
        -W -Wall -Werror -std=c++0x -pedantic \
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
endef


$(PKG)_BUILD_SHARED = $(subst -static ,-shared ,\
                      $($(PKG)_BUILD))
