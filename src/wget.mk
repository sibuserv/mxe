# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := wget
$(PKG)_WEBSITE  := https://www.gnu.org/software/wget/
$(PKG)_VERSION  := 1.21.1
$(PKG)_CHECKSUM := db9bbe5347e6faa06fc78805eeb808b268979455ead9003a608569c9d4fc90ad
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.lz
$(PKG)_URL      := https://ftp.gnu.org/gnu/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc gnutls libidn2 libntlm pcre2 pthreads

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://git.savannah.gnu.org/cgit/wget.git/refs/' | \
    $(SED) -n "s,.*<a href='/cgit/wget.git/tag/?h=v\([0-9.]*\)'>.*,\1,p" | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-ssl=gnutls \
        CFLAGS='-DIN6_ARE_ADDR_EQUAL=IN6_ADDR_EQUAL -D_WIN32_WINNT=0x0600 $(if $(BUILD_STATIC),-DGNUTLS_INTERNAL_BUILD,)'\
        LDFLAGS='$(if $(BUILD_SHARED),-Wl$(comma)--allow-multiple-definition,)'
    $(MAKE) -C '$(1)/lib' -j '$(JOBS)'
    $(MAKE) -C '$(1)/src' -j '$(JOBS)' install-binPROGRAMS
endef
