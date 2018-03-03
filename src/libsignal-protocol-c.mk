# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsignal-protocol-c
$(PKG)_WEBSITE  := https://github.com/signalapp/libsignal-protocol-c
$(PKG)_DESCR    := libsignal-protocol-c
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.3.1
$(PKG)_CHECKSUM := 1afc195cc87153ea5178b485a2bf9f4791c03fd70c9b2e3c1ecc55bbb64c9fce
$(PKG)_GH_CONF  := signalapp/libsignal-protocol-c/tags, v
$(PKG)_DEPS     := cc pthreads

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -DPKG_CONFIG_EXECUTABLE='$(PREFIX)/bin/$(TARGET)-pkg-config'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
