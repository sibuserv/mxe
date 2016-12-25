# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qt5
$(PKG)_WEBSITE  := http://qt-project.org/
$(PKG)_DESCR    := Qt
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_DEPS     := qtbase qtconnectivity qtscript qtserialport qtsvg qttools qtwebsockets
