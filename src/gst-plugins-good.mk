# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := gst-plugins-good
$(PKG)_WEBSITE  := https://gstreamer.freedesktop.org/modules/gst-plugins-good.html
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.14.4
$(PKG)_CHECKSUM := 5f8b553260cb0aac56890053d8511db1528d53cae10f0287cfce2cb2acc70979
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://gstreamer.freedesktop.org/src/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc glib gst-plugins-base gstreamer jpeg libpng speex

$(PKG)_UPDATE = $(subst gstreamer/refs,gst-plugins-good/refs,$(gstreamer_UPDATE))

define $(PKG)_BUILD
    # The value for WAVE_FORMAT_DOLBY_AC3_SPDIF comes from vlc and mplayer:
    #   https://www.videolan.org/developers/vlc/doc/doxygen/html/vlc__codecs_8h-source.html
    #   https://lists.mplayerhq.hu/pipermail/mplayer-cvslog/2004-August/019283.html
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --disable-debug \
        --disable-examples \
        --disable-aalib \
        $(if $(BUILD_SHARED), --disable-shout2) \
        --disable-x
    $(MAKE) -C '$(BUILD_DIR)' -j $(JOBS) CFLAGS='-DWAVE_FORMAT_DOLBY_AC3_SPDIF=0x0092'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install CFLAGS='-DWAVE_FORMAT_DOLBY_AC3_SPDIF=0x0092'

    # some .dlls are installed to lib - no obvious way to change
    $(if $(BUILD_SHARED),
        $(INSTALL) -d '$(PREFIX)/$(TARGET)/bin/gstreamer-1.0'
        mv -vf '$(PREFIX)/$(TARGET)/lib/gstreamer-1.0/'*.dll '$(PREFIX)/$(TARGET)/bin/gstreamer-1.0/'
    )
endef
