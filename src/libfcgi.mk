# This file is part of MXE.
# See index.html for further information.

PKG             := libfcgi
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.4.0
$(PKG)_CHECKSUM := 940ac5e857d63756726068ac3043319289d886c9
$(PKG)_SUBDIR   := libfcgi-$($(PKG)_VERSION).orig
$(PKG)_FILE     := libfcgi_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_URL      := http://ftp.debian.org/debian/pool/main/libf/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.debian.org/debian/pool/main/libf/libfcgi' | \
    $(SED) -n 's,.*libfcgi_\([0-9][^<]*\)\.orig\.tar\.gz,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && autoreconf -fi
    cd '$(1)' && \
    CPPFLAGS="$(CPPFLAGS)" \
    CFLAGS="$(CFLAGS)" \
    CXXFLAGS="$(CXXFLAGS)" \
    LDFLAGS="$(LDFLAGS)" \
    ./configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
