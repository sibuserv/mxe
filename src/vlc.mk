# This file is part of MXE.
# See index.html for further information.

PKG             := vlc
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.2.1
$(PKG)_CHECKSUM := ee8535c5966217bc2069a74c1d4e8c32609656e9
$(PKG)_SUBDIR   := vlc-$($(PKG)_VERSION)
$(PKG)_FILE     := vlc-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://download.videolan.org/pub/videolan/vlc/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc glew

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://download.videolan.org/pub/videolan/vlc/' | \
    $(SED) -n 's,.*<a[^>]*>\([0-9][^<]*\)/<.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    mkdir -p '$(1)/contrib/win32'
    cd '$(1)/contrib/win32' && \
        ../bootstrap \
        --host='$(TARGET)' \
        --build='$(BUILD)' \
        --prefix='$(PREFIX)/$(TARGET)'
    cd '$(1)' && autoreconf -fi
    cd '$(1)' && \
    CPPFLAGS="$(CPPFLAGS)" \
    CFLAGS="$(CFLAGS)" \
    CXXFLAGS="$(CXXFLAGS)" \
    LDFLAGS="$(LDFLAGS)" \
    ./configure \
        --host='$(TARGET)' \
        --build='$(BUILD)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --disable-shared \
        --enable-static \
        --disable-gles1 \
        --disable-gles2 \
        --disable-libxml2 \
        --disable-libgcrypt \
        --disable-avformat \
        --disable-swscale \
        --disable-avcodec \
        --disable-opus \
        --disable-opensles \
        --disable-taglib \
        --disable-zvbi \
        --disable-libass \
        --disable-mod \
        --disable-mad \
        --disable-shared \
        --disable-vorbis \
        --disable-dvbpsi \
        --disable-dvdread \
        --disable-dvdnav \
        --disable-mkv \
        --disable-live555 \
        --disable-realrtsp \
        --disable-vlc \
        --disable-nls \
        --disable-update-check \
        --disable-vlm \
        --disable-dbus \
        --disable-lua \
        --disable-vcd \
        --disable-v4l2 \
        --disable-gnomevfs \
        --disable-bluray \
        --disable-linsys \
        --disable-decklink \
        --disable-libva \
        --disable-dv1394 \
        --disable-sid \
        --disable-gme \
        --disable-tremor \
        --disable-dca \
        --disable-sdl-image \
        --disable-fluidsynth \
        --disable-jack \
        --disable-pulse \
        --disable-alsa \
        --disable-samplerate \
        --disable-sdl \
        --disable-xcb \
        --disable-atmo \
        --disable-qt \
        --disable-skins2 \
        --disable-mtp \
        --disable-notify \
        --disable-svg \
        --disable-udev \
        --disable-caca \
        --disable-goom \
        --disable-projectm \
        --disable-sout \
        --disable-faad \
        --disable-x264 \
        --disable-schroedinger \
        --disable-a52
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
