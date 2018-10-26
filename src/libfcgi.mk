# This file is part of MXE.
# See index.html for further information.

PKG             := libfcgi
$(PKG)_WEBSITE  := https://github.com/FastCGI-Archives
$(PKG)_DESCR    := FastCGI
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1b3e1b2
$(PKG)_CHECKSUM := 8781cb811dbc7e09b89d3481e3b3baaba42decb7b29663062031eb9262ab685a
$(PKG)_GH_CONF  := FastCGI-Archives/fcgi2/branches/master
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && autoreconf -fi
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS)

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install $(MXE_DISABLE_CRUFT)

    # Test
    '$(TARGET)-g++' \
        -W -Wall -Werror -std=c++0x -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' fcgi --cflags --libs`
endef
