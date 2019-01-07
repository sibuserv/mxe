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
$(PKG)_DEPS     := cc libxml2 libxslt libwebp qtbase qtmultimedia qtquickcontrols \
                   qtsensors qtwebchannel sqlite

define $(PKG)_BUILD_SHARED
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DCMAKE_INSTALL_PREFIX=$(PREFIX)/$(TARGET)/qt5 \
        -DCMAKE_CXX_FLAGS='-fpermissive' \
        -DEGPF_DEPS='Qt5Core Qt5Gui Qt5Multimedia Qt5Widgets Qt5WebKit' \
        -DPORT=Qt \
        -DENABLE_GEOLOCATION=OFF \
        -DENABLE_MEDIA_SOURCE=ON \
        -DENABLE_WEB_AUDIO=ON \
        -DUSE_GSTREAMER=OFF \
        -DUSE_MEDIA_FOUNDATION=OFF \
        -DUSE_QT_MULTIMEDIA=ON
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # build test manually
    # add $(BUILD_TYPE_SUFFIX) for debug builds - see qtbase.mk
    $(TARGET)-g++ \
        -W -Wall -std=c++14 \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `$(TARGET)-pkg-config Qt5WebKitWidgets --cflags --libs`

    # batch file to run test programs
    (printf 'set PATH=..\\lib;..\\qt5\\bin;..\\qt5\\lib;%%PATH%%\r\n'; \
     printf 'set QT_QPA_PLATFORM_PLUGIN_PATH=..\\qt5\\plugins\r\n'; \
     printf 'test-$(PKG).exe\r\n'; \
     printf 'cmd\r\n';) \
     > '$(PREFIX)/$(TARGET)/bin/test-$(PKG).bat'
endef
