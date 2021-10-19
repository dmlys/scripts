setlocal
rem cppdb build
set source_dir=.
set version=0.3.1
set vcver=vc142
set thirdparty_dir=E:\Projects\thirdparty

call :build_platform %vcver% x86
call :build_platform %vcver% x64

endlocal
goto :eof

rem %1 - %vcver% %2 - platform
:build_platform
setlocal
call %1vars %2

set INCLUDE=%INCLUDE%;%thirdparty_dir%\%1-%2\include
set LIB=%LIB%;%thirdparty_dir%\%1-%2\lib

rd lib bin include /q/s > nul
mkdir lib bin include\cppdb

call :build_lib -DCMAKE_BUILD_TYPE=RelWithDebInfo 
call :build_lib -DCMAKE_BUILD_TYPE=Debug          -DCMAKE_DEBUG_POSTFIX=d

rem includes
copy %source_dir%\cppdb\*.h include\cppdb

set arname=cppdb-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib bin include 

rd build lib bin include /q/s

endlocal
goto :eof

rem args passed to cmake
:build_lib
rd build /q/s
mkdir build
pushd build

cmake .. -G "NMake Makefiles" %*
nmake

popd
rem libs and static pdb
copy build\*.lib           lib
copy build\libcppdb*.pdb   lib
rem dll and nonstatic pdb
copy build\*.dll        bin
copy build\cppdb*.pdb   bin

goto :eof