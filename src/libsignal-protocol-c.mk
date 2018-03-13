# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsignal-protocol-c
$(PKG)_WEBSITE  := https://github.com/signalapp/libsignal-protocol-c
$(PKG)_DESCR    := libsignal-protocol-c
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 9e10362fce9072b104e6d5a51d6f56d939d1f36e
$(PKG)_CHECKSUM := e97e9e707a60e21ef85634e2de9b1360c9830793cc3e8ae5fc58008fd3565f75
$(PKG)_SUBDIR   := libsignal-protocol-c-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://github.com/signalapp/libsignal-protocol-c/archive/$($(PKG)_VERSION).tar.gz
#$(PKG)_GH_CONF  := signalapp/libsignal-protocol-c/tags, v
$(PKG)_DEPS     := cc pthreads

$(PKG)_UPDATE    = $(call MXE_GET_GITHUB_SHA, signalapp/libsignal-protocol-c, master)

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -DPKG_CONFIG_EXECUTABLE='$(PREFIX)/bin/$(TARGET)-pkg-config'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
