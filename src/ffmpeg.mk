# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ffmpeg
$(PKG)_WEBSITE  := https://ffmpeg.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.4.1
$(PKG)_CHECKSUM := f3443e20154a590ab8a9eef7bc951e8731425efc75b44ff4bee31d8a7a574a2c
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://ffmpeg.org/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc bzip2 yasm zlib

# DO NOT ADD fdk-aac OR openssl SUPPORT.
# Although they are free softwares, their licenses are not compatible with
# the GPL, and we'd like to enable GPL in our default ffmpeg build.
# See docs/index.html#potential-legal-issues

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ffmpeg.org/releases/' | \
    $(SED) -n 's,.*ffmpeg-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc\|git' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && \
    CPPFLAGS="$(CPPFLAGS)" \
    CFLAGS="$(CFLAGS)" \
    CXXFLAGS="$(CXXFLAGS)" \
    LDFLAGS="$(LDFLAGS)" \
    ./configure \
        --cross-prefix='$(TARGET)'- \
        --enable-cross-compile \
        --arch=$(firstword $(subst -, ,$(TARGET))) \
        --target-os=mingw32 \
        --prefix='$(PREFIX)/$(TARGET)' \
        $(if $(BUILD_STATIC), \
            --enable-static --disable-shared , \
            --disable-static --enable-shared ) \
        --yasmexe='$(TARGET)-yasm' \
        --disable-debug \
        --disable-pthreads \
        --enable-w32threads \
        --disable-doc \
        --enable-avresample \
        --enable-gpl \
        --enable-version3 \
        --extra-libs='-mconsole' \
        --enable-avisynth \
        --disable-libass \
        --disable-libbluray \
        --disable-libbs2b \
        --disable-libcaca \
        --disable-libmp3lame \
        --disable-libopencore-amrnb \
        --disable-libopencore-amrwb \
        --disable-libopus \
        --disable-libspeex \
        --disable-libtheora \
        --disable-libvidstab \
        --disable-libvo-amrwbenc \
        --disable-libvorbis \
        --disable-libvpx \
        --disable-libx264 \
        --disable-libxvid \
        --disable-programs \
        --disable-iconv \
        --disable-openssl \
        --disable-gnutls \
        --disable-schannel \
        --disable-securetransport

    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
