# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtwebkit
$(PKG)_WEBSITE  := https://github.com/annulen/webkit
$(PKG)_DESCR    := Qt WebKit
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.212
$(PKG)_CHECKSUM := 283b907ea324a2c734e3983c73fc27dbd8b33e2383c583de41842ee84d648a3e
$(PKG)_SUBDIR   := qtwebkit-everywhere-src-$($(PKG)_VERSION)
$(PKG)_FILE     := qtwebkit-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.qt.io/snapshots/ci/qtwebkit/$($(PKG)_VERSION)/latest/src/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := cc libxml2 libxslt qtbase qtmultimedia qtquickcontrols sqlite \
                   qtsensors qtwebchannel

define $(PKG)_BUILD_SHARED
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DCMAKE_INSTALL_PREFIX=$(PREFIX)/$(TARGET)/qt5 \
        -DSHARED_CORE=$(CMAKE_SHARED_BOOL) \
        -DQT_STATIC_BUILD=$(CMAKE_STATIC_BOOL) \
        -DENABLE_GEOLOCATION=OFF \
        -DPORT=Qt \
        -DENABLE_INSPECTOR_UI=OFF \
        -DENABLE_DEVICE_ORIENTATION=OFF \
        -DUSE_QT_MULTIMEDIA=OFF \
        -DENABLE_VIDEO=OFF \
        -DENABLE_QT_WEBCHANNEL=OFF \
        -DENABLE_GEOLOCATION=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # build test manually
    # add $(BUILD_TYPE_SUFFIX) for debug builds - see qtbase.mk
    $(TARGET)-g++ \
        -W -Wall -std=c++11 \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `$(TARGET)-pkg-config Qt5WebKitWidgets --cflags --libs`

    # batch file to run test programs
    (printf 'set PATH=..\\lib;..\\qt5\\bin;..\\qt5\\lib;%%PATH%%\r\n'; \
     printf 'set QT_QPA_PLATFORM_PLUGIN_PATH=..\\qt5\\plugins\r\n'; \
     printf 'test-$(PKG).exe\r\n'; \
     printf 'cmd\r\n';) \
     > '$(PREFIX)/$(TARGET)/bin/test-$(PKG).bat'
endef
