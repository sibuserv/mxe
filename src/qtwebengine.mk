# This file is part of MXE.
# See index.html for further information.

PKG             := qtwebengine
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := 985762fff5cd8a1a0d2a644a4a51238676898685f9ff1a78c3f2800025d6dc5d
$(PKG)_SUBDIR    = $(subst qtbase,qtwebengine,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtwebengine,$(qtbase_FILE))
$(PKG)_URL       = $(subst qtbase,qtwebengine,$(qtbase_URL))
$(PKG)_DEPS     := gcc qtbase qtquickcontrols

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD
    # invoke qmake with removed debug options as a workaround for
    # https://bugreports.qt-project.org/browse/QTBUG-30898
    cd '$(1)' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake' CONFIG-='debug debug_and_release'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
