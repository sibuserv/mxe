# This file is part of MXE.
# See index.html for further information.

PKG             := gdal
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.0.1
$(PKG)_CHECKSUM := b55f794768e104a2fd0304eaa61bb8bda3dc7c4e14f2c9d0913baca3e55b83ab
$(PKG)_SUBDIR   := gdal-$($(PKG)_VERSION)
$(PKG)_FILE     := gdal-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://download.osgeo.org/gdal/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_URL_2    := ftp://ftp.remotesensing.org/gdal/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc proj zlib libpng tiff jpeg giflib expat

CXXFLAGS := -Os -fdata-sections -ffunction-sections $(CPPFLAGS) -D_WIN32_WINNT=0x0600

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://trac.osgeo.org/gdal/wiki/DownloadSource' | \
    $(SED) -n 's,.*gdal-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && autoreconf -fi -I ./m4
    # The option '--with-threads=no' means native win32 threading without pthread.
    # mysql uses threading from Vista onwards - '-D_WIN32_WINNT=0x0600'
    cd '$(1)' && \
    CPPFLAGS="$(CPPFLAGS)" \
    CFLAGS="$(CFLAGS)" \
    CXXFLAGS="$(CXXFLAGS)" \
    LDFLAGS="$(LDFLAGS)" \
    ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-static-proj4='$(PREFIX)/$(TARGET)' \
        --with-libz='$(PREFIX)/$(TARGET)' \
        --with-png='$(PREFIX)/$(TARGET)' \
        --with-libtiff='$(PREFIX)/$(TARGET)' \
        --with-jpeg='$(PREFIX)/$(TARGET)' \
        --with-gif='$(PREFIX)/$(TARGET)' \
        --with-expat='$(PREFIX)/$(TARGET)' \
        --with-libjson-c=internal \
        --with-geotiff=internal \
        --with-threads=no \
        --with-openjpeg=no \
        --with-curl=no \
        --with-xml2=no \
        --with-geos=no \
        --with-bsb=no \
        --with-ogr=no \
        --with-grib=no \
        --with-pam=no \
        --with-gta=no \
        --with-pg=no \
        --with-sqlite3=no \
        --with-jasper=no \
        --with-hdf4=no \
        --with-hdf5=no \
        --with-odbc=no \
        --with-xerces=no \
        --with-grass=no \
        --with-libgrass=no \
        --with-spatialite=no \
        --with-cfitsio=no \
        --with-pcraster=no \
        --with-pcidsk=no \
        --with-ogdi=no \
        --with-fme=no \
        --with-ecw=no \
        --with-kakadu=no \
        --with-mrsid=no \
        --with-jp2mrsid=no \
        --with-msg=no \
        --with-oci=no \
        --with-mysql=no \
        --with-netcdf=no \
        --with-ingres=no \
        --with-dods-root=no \
        --with-dwgdirect=no \
        --with-idb=no \
        --with-sde=no \
        --with-epsilon=no \
        --with-perl=no \
        --with-php=no \
        --with-ruby=no \
        --with-python=no \
        --with-armadillo=no \
        LIBS="-ljpeg -lsecur32 `'$(TARGET)-pkg-config' --libs openssl libtiff-4`"

    $(MAKE) -C '$(1)'       -j '$(JOBS)' lib-target
    $(MAKE) -C '$(1)'       -j '$(JOBS)' install-lib
    $(MAKE) -C '$(1)/port'  -j '$(JOBS)' install
    $(MAKE) -C '$(1)/gcore' -j '$(JOBS)' install
    $(MAKE) -C '$(1)/frmts' -j '$(JOBS)' install
    $(MAKE) -C '$(1)/alg'   -j '$(JOBS)' install
    $(MAKE) -C '$(1)/ogr'   -j '$(JOBS)' install OGR_ENABLED=
    $(MAKE) -C '$(1)/apps'  -j '$(JOBS)' install
    ln -sf '$(PREFIX)/$(TARGET)/bin/gdal-config' '$(PREFIX)/bin/$(TARGET)-gdal-config'
endef
