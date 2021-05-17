# This is a template of configuration file for MXE. See
# docs/index.html for more extensive documentations.

# This variable controls the number of compilation processes
# within one package ("intra-package parallelism").
#JOBS := 

# This variable controls where intermediate files are created
# this is necessary when compiling inside a virtualbox shared
# directory. Some commands like strip fail in there with Protocol error
# default is the current directory
#MXE_TMP := /tmp

# This variable controls the targets that will build.
MXE_TARGETS := x86_64-w64-mingw32.shared i686-w64-mingw32.shared \
               x86_64-w64-mingw32.static i686-w64-mingw32.static
#MXE_TARGETS := x86_64-w64-mingw32.shared i686-w64-mingw32.shared

# This variable controls which plugins are in use.
# See plugins/README.md for further information.
#override MXE_PLUGIN_DIRS += plugins/apps plugins/native
MXE_PLUGIN_DIRS += plugins/gcc11

# This variable controls the download mirror for SourceForge,
# when it is used. Enabling the value below means auto.
#SOURCEFORGE_MIRROR := downloads.sourceforge.net

# The three lines below makes `make` build these "local
# packages" instead of all packages.
#LOCAL_PKG_LIST := curl file flac lzo pthreads vorbis wxwidgets
LOCAL_PKG_LIST := aspell hunspell jsoncpp lua minizip miniupnpc \
                  libfcgi libotr libsignal-protocol-c tidy-html5 \
                  qtbase qttools qttranslations qtmultimedia qtwebkit \
                  gstreamer gst-plugins-bad gst-plugins-good

.DEFAULT_GOAL  := local-pkg-list
local-pkg-list: $(LOCAL_PKG_LIST)

