# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := curl
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 7.52.0
$(PKG)_CHECKSUM := c8f0114c7c72c8627d716416326593d061274b208cdf123c418c20c6dbe009c2
$(PKG)_SUBDIR   := curl-$($(PKG)_VERSION)
$(PKG)_FILE     := curl-$($(PKG)_VERSION).tar.lzma
$(PKG)_URL      := http://curl.haxx.se/download/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc gnutls libidn libssh2

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://curl.haxx.se/download/?C=M;O=D' | \
    $(SED) -n 's,.*curl-\([0-9][^"]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && \
    CPPFLAGS="$(CPPFLAGS)" \
    CFLAGS="$(CFLAGS)" \
    CXXFLAGS="$(CXXFLAGS)" \
    LDFLAGS="$(LDFLAGS)" \
    ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-gnutls \
        --without-ssl \
        --with-libidn \
        --enable-sspi \
        --enable-ipv6 \
        --with-libssh2
    $(MAKE) -C '$(1)' -j '$(JOBS)' install $(MXE_DISABLE_DOCS)
    ln -sf '$(PREFIX)/$(TARGET)/bin/curl-config' '$(PREFIX)/bin/$(TARGET)-curl-config'

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-curl.exe' \
        `'$(TARGET)-pkg-config' libcurl --cflags --libs`
endef
