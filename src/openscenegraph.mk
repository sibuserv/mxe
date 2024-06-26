# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := openscenegraph
$(PKG)_WEBSITE  := http://www.openscenegraph.org/
$(PKG)_DESCR    := OpenSceneGraph
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.6.5
$(PKG)_CHECKSUM := aea196550f02974d6d09291c5d83b51ca6a03b3767e234a8c0e21322927d1e12
$(PKG)_GH_CONF  := openscenegraph/OpenSceneGraph/tags, OpenSceneGraph-
$(PKG)_DEPS     := cc freetype curl gdal giflib jpeg libpng openthreads tiff zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.openscenegraph.org/index.php/download-section/stable-releases' | \
    $(SED) -n 's,.*OpenSceneGraph/tree/OpenSceneGraph-\([0-9]*\.[0-9]*[02468]\.[^<]*\)">.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -DCMAKE_CXX_FLAGS='-D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS' \
        -DCMAKE_HAVE_PTHREAD_H=OFF \
        -DOSG_DETERMINE_WIN_VERSION=OFF \
        -DPKG_CONFIG_EXECUTABLE='$(PREFIX)/bin/$(TARGET)-pkg-config' \
        -DDYNAMIC_OPENTHREADS=$(CMAKE_SHARED_BOOL) \
        -DDYNAMIC_OPENSCENEGRAPH=$(CMAKE_SHARED_BOOL) \
        -DBUILD_OSG_APPLICATIONS=OFF \
        -DOPENTHREADS_ATOMIC_USE_MUTEX=ON \
	$(PKG_CMAKE_OPTS)

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
