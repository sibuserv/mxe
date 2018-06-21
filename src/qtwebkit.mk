# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtwebkit
$(PKG)_WEBSITE  := https://github.com/annulen/webkit
$(PKG)_DESCR    := Qt WebKit
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 72cfbd7
$(PKG)_CHECKSUM := 7773f97599486c4e54973373637e4e1118b581fd70c2a45c0f2e69d862088b80
$(PKG)_GH_CONF  := qt/qtwebkit/branches/5.212
$(PKG)_DEPS     := cc libxml2 libxslt qtbase qtmultimedia qtquickcontrols sqlite \
                   qtsensors qtwebchannel

define $(PKG)_BUILD_SHARED
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DSHARED_CORE=$(CMAKE_SHARED_BOOL) \
        -DQT_STATIC_BUILD=$(CMAKE_STATIC_BOOL) \
        -DENABLE_GEOLOCATION=OFF \
        -DPORT=Qt
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 installl

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
