# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := gcc
$(PKG)_WEBSITE  := http://gcc.gnu.org/
$(PKG)_DESCR    := GCC
$(PKG)_IGNORE   := 6%
$(PKG)_VERSION  := 5.4.0
$(PKG)_CHECKSUM := 608df76dec2d34de6558249d8af4cbee21eceddbcb580d666f7a5a583ca3303a
$(PKG)_SUBDIR   := gcc-$($(PKG)_VERSION)
$(PKG)_FILE     := gcc-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := http://ftp.gnu.org/pub/gnu/gcc/gcc-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_URL_2    := ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := binutils mingw-w64

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnu.org/gnu/gcc/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="gcc-\([0-9][^"]*\)/".*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_CONFIGURE
    # configure gcc
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        --target='$(TARGET)' \
        --build='$(BUILD)' \
        --prefix='$(PREFIX)' \
        --libdir='$(PREFIX)/lib' \
        --enable-languages='c,c++,objc,fortran' \
        --enable-version-specific-runtime-libs \
        --with-gcc \
        --with-gnu-ld \
        --with-gnu-as \
        --disable-nls \
        $(if $(BUILD_STATIC),--disable-shared) \
        --disable-multilib \
        --without-x \
        --disable-win32-registry \
        --enable-threads=$(MXE_GCC_THREADS) \
        $(MXE_GCC_EXCEPTION_OPTS) \
        --enable-libgomp \
        --with-gmp='$(PREFIX)/$(BUILD)' \
        --with-isl='$(PREFIX)/$(BUILD)' \
        --with-mpc='$(PREFIX)/$(BUILD)' \
        --with-mpfr='$(PREFIX)/$(BUILD)' \
        --with-as='$(PREFIX)/bin/$(TARGET)-as' \
        --with-ld='$(PREFIX)/bin/$(TARGET)-ld' \
        --with-nm='$(PREFIX)/bin/$(TARGET)-nm' \
        $(shell [ `uname -s` == Darwin ] && echo "LDFLAGS='-Wl,-no_pie'") \
        $($(PKG)_CONFIGURE_OPTS)
endef

define $(PKG)_BUILD_mingw-w64
    # install mingw-w64 headers
    $(call PREPARE_PKG_SOURCE,mingw-w64,$(BUILD_DIR))
    mkdir '$(BUILD_DIR).headers'
    cd '$(BUILD_DIR).headers' && '$(BUILD_DIR)/$(mingw-w64_SUBDIR)/mingw-w64-headers/configure' \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --enable-sdk=all \
        --enable-idl \
        --enable-secure-api \
        $(mingw-w64-headers_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR).headers' install

    # build standalone gcc
    $($(PKG)_CONFIGURE)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' all-gcc
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(INSTALL_STRIP_TOOLCHAIN)-gcc

    # build mingw-w64-crt
    mkdir '$(BUILD_DIR).crt'
    cd '$(BUILD_DIR).crt' && '$(BUILD_DIR)/$(mingw-w64_SUBDIR)/mingw-w64-crt/configure' \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        @gcc-crt-config-opts@
    $(MAKE) -C '$(BUILD_DIR).crt' -j '$(JOBS)' || $(MAKE) -C '$(BUILD_DIR).crt' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR).crt' -j 1 $(INSTALL_STRIP_TOOLCHAIN)

    # build posix threads
    mkdir '$(BUILD_DIR).pthreads'
    cd '$(BUILD_DIR).pthreads' && '$(BUILD_DIR)/$(mingw-w64_SUBDIR)/mingw-w64-libraries/winpthreads/configure' \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR).pthreads' -j '$(JOBS)' || $(MAKE) -C '$(BUILD_DIR).pthreads' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR).pthreads' -j 1 $(INSTALL_STRIP_TOOLCHAIN)

    # build rest of gcc
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(INSTALL_STRIP_TOOLCHAIN)

    $($(PKG)_POST_BUILD)
endef

define $(PKG)_POST_BUILD
    # - no non-trivial way to configure installation of *.dlls
    #   each sudbir has it's own variations of variables like:
    #       `toolexeclibdir` `install-toolexeclibLTLIBRARIES` etc.
    #   and maintaining those would be cumbersome
    # - shared libgcc isn't installed to version-specific locations
    # - need to keep `--enable-version-specific-runtime-libs` otherwise
    #   libraries go directly into $(PREFIX)/$(TARGET)/lib and are
    #   harder to cleanup
    # - ignore rm failure as parallel build may have cleaned up, but
    #   don't wildcard all libs so future additions will be detected
    $(and $(BUILD_SHARED),
    $(MAKE) -C '$(BUILD_DIR)/$(TARGET)/libgcc' -j 1 \
        toolexecdir='$(PREFIX)/$(TARGET)/bin' \
        SHLIB_SLIBDIR_QUAL= \
        install-shared
    mv  -v '$(PREFIX)/lib/gcc/$(TARGET)/$($(PKG)_VERSION)/'*.dll '$(PREFIX)/$(TARGET)/bin/'
    -rm -v '$(PREFIX)/lib/gcc/$(TARGET)/'libgcc_s*.dll
    -rm -v '$(PREFIX)/lib/gcc/$(TARGET)/lib/'libgcc_s*.a
    -rmdir '$(PREFIX)/lib/gcc/$(TARGET)/lib/')

    # cc1libdir isn't passed to subdirs so install correctly and rm
    $(MAKE) -C '$(BUILD_DIR)/libcc1' -j 1 install cc1libdir='$(PREFIX)/lib/gcc/$(TARGET)/$($(PKG)_VERSION)'
    -rm -f '$(PREFIX)/lib/'libcc1*
endef

$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @gcc-crt-config-opts@,--disable-lib32,$($(PKG)_BUILD_mingw-w64))
$(PKG)_BUILD_i686-w64-mingw32   = $(subst @gcc-crt-config-opts@,--disable-lib64,$($(PKG)_BUILD_mingw-w64))
