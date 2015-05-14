# This file is part of MXE.
# See index.html for further information.

PKG             := qt5
$(PKG)_IGNORE    = $(qtbase_IGNORE)
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM  = $(qtbase_CHECKSUM)
$(PKG)_SUBDIR    = $(qtbase_SUBDIR)
$(PKG)_FILE      = $(qtbase_FILE)
$(PKG)_URL       = $(qtbase_URL)
$(PKG)_DEPS     := qtbase qttools qtserialport qtscript qtwebsockets

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef
