./configure 
    -prefix ~/.local/opt/qt-5.13.1 # куда интсалить   
    -opensource -confirm-license   # какую лицензию использовать -commercial или -opensource
    
    # тип сборки debug/release
    # -developer-build Compile and link Qt for developing Qt itself (exports for auto-tests, extra checks, etc.)
    -debug   -no-optimize-debug -gdb-index -developer-build 
    -release -force-debug-info  -gdb-index 
    -debug-and-release # windows/apple only

    -shared, -static # тип линковки
    -framework # Apple only

    -plugin-manifests .... Embed manifests into plugins [no] (Windows only)
    -static-runtime ...... With -static, use static runtime [no] (Windows only)

    -c++std c++17, c++2a
    # отключаем сборку тестов и примеров
    -nomake tests -nomake examples #-no-icu -mp

    # jom?
    -make-tool <tool> .... Use <tool> to build qmake [nmake] (Windows only)


linux примеры:
  #debug   ./configure -prefix ~/.local/opt/qt-5.13.1 -opensource -confirm-license -debug   -no-optimize-debug -gdb-index -developer-build -c++std c++17 -nomake tests -nomake examples
  #release ./configure -prefix ~/.local/opt/qt-5.13.1 -opensource -confirm-license -release -force-debug-info  -gdb-index                  -c++std c++17 -nomake tests -nomake examples

windows примеры:
  LLVM требуется для документации, также нужны perl, python
  set LLVM_INSTALL_DIR=E:\LLVM
  configure.bat -prefix E:\Projects\thirdparty_work\qt-5.13.1-vc141-x64 ^
                -opensource -confirm-license -debug-and-release -force-debug-info ^
                -no-plugin-manifests -mp -nomake tests -nomake examples ^
                -opengl desktop -no-icu -no-angle 


make
make install
опционально добавить -j что бы ускорить
