##
## On linux when building shared library all code must be compiled with -fPIC, including code in static libraries.
## So if we have static library which is used later when building shared library - -fPIC must be used when building first one
##
## https://gcc.gnu.org/wiki/Visibility
## There is also question of visibility, by default anything is visible. This can be changed with -fvisibility=hidden, but visibility attribute is bound to code at compile time and can't be changed later.
##
## This is not a problem for shared library code, but if static library is compiled without -fvisibility=hidden - all of it symbols will have visibility=default(visible).
## It has two consequences: 
##   1. Those symbols will be exported from shared library, as if this is shared library own code.
##      In practice, for example, your shared library will export OpenSSL symbols and actually act like OpenSSL shared library sorta provider, 
##      potentially conflicting with OpenSSL own libraries bound by libcrypt, libssl, which could lead to nasty things, like crashes.
##   
##   2. All visible symbols will be exported - included into shared library.
##      If your shared library uses only several symbols from static library and in any way depends on other - those can be removed/dropped and not included into resulting shared library.
##      But because they all are visible, they all must be included, non will be dropped - shared library includes all code from static library and become fatter, potentially much fatter.
## 
## Summary: When creating shared library, all code, including code from static libraries, must be compiled with -fPIC.
##          Highly desirable that all code, including code from static libraries, have to be compiled with -fvisibility=hidden (and -fvisibility-inlines-hidden)
##          Please not that if exceptions be caught across shared libraries boundaries - they must be visible. Read: https://gcc.gnu.org/wiki/Visibility#Problems_with_C.2B-.2B-_exceptions_.28please_read.21.29
## 
##
## Note: Exported symbols from shared library can be controlled via version script, sort of like msvc .def files
##       version script file should be like:
##         {
##             global: symbol; symbol_with_wild_card*;
##             local: *;
##         };
##
##    This will add to export table only symbols symbols and those starting with symbol_with_wild_card.
##    All other, including foreign from other static libraries with visibility=default will not be exported.
##    They still will be included, even if not used, but at least they will not conflict with symbols from other shared libraries
##

###########################################################################
## Some examples how to build some libraries as static with prober flags 
###########################################################################


###########################################################################
##                         xerces-c
###########################################################################
## xerces-c for linux can be build like this
./configure --prefix /home/dima/.local/opt/xerces-c-3.2.1 --disable-network --enable-transcoder-gcuiconv

## but if static library is intended to be used for building another shared library, it should be built like this:
 CFLAGS="-fPIC -fvisibility=hidden" CXXFLAGS="-fPIC -fvisibility=hidden -fvisibility-inlines-hidden" \
 ./configure --prefix /home/dima/.local/opt/xerces-c-3.2.1 --disable-network --enable-transcoder-gnuiconv --enable-shared=no

## --with-pic=yes will enable -fPIC, but not -fvisibility, so better use variant above
# ./configure --prefix /home/dima/.local/opt/xerces-c-3.2.1 --disable-network --enable-transcoder-gnuiconv --enable-shared=no --with-pic=yes


###########################################################################
##                         libfmt
###########################################################################
## fmt can be built with cmake .. -DCMAKE_INSTALL_PREFIX=~/.local/opt/fmt-8.1.1 by default, but if static library is inteded to be used for building another shared library, it must be compiled with -fPIC(linux/unix requirements)
cmake .. -DCMAKE_INSTALL_PREFIX=~/.local/opt/fmt-8.1.1 -DBUILD_SHARED_LIBS=OFF  -DCMAKE_POSITION_INDEPENDENT_CODE=ON

## It is also good idea to compile with -fvisibility=hidden, and with cmake those flags can by turn on globally(probably) with: -DCMAKE_CXX_VISIBILITY_PRESET=ON -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON 
## But FMT already enables those flags(you can see this with make VERBOSE=1), so it's unneeded
# cmake .. -DCMAKE_INSTALL_PREFIX=~/.local/opt/fmt-8.1.1 -DBUILD_SHARED_LIBS=OFF  -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_VISIBILITY_PRESET=ON -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON 


###########################################################################
##                         OpenSSL
###########################################################################
## it looks like OpenSSL is always built with -fPIC, but visibility must be set by hand
CFLAGS="-fvisibility=hidden" CXXFLAGS="-fvisibility=hidden -fvisibility-inlines-hidden" \
./config --prefix=$HOME/.local/opt/openssl-1.1.1l no-hw no-shared no-asm no-zlib
