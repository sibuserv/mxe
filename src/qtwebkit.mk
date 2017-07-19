# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtwebkit
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := 9ca72373841f3a868a7bcc696956cdb0ad7f5e678c693659f6f0b919fdd16dfe
$(PKG)_SUBDIR    = $(subst qtbase,qtwebkit,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtwebkit,$(qtbase_FILE))
$(PKG)_URL       = https://download.qt.io/community_releases/5.6/$(qtbase_VERSION)/qtwebkit-opensource-src-$(qtbase_VERSION).tar.xz
$(PKG)_DEPS     := gcc qtbase qtmultimedia qtquickcontrols sqlite

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD_SHARED
    cd '$(BUILD_DIR)' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake' '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
