setlocal
rem libp11 build
set source_dir=src
set libname=libp11
set version=0.4.12
set vcver=vc142
set vcvars=vc142vars

call :build_platform %vcvars% x86
call :build_platform %vcvars% x64

endlocal
goto :eof

rem %1 - %vcver%vars %2 - platform
:build_platform
setlocal
call %1 %2

rd build include lib /q/s > nul
mkdir build include lib

rem /Z7 - debug info
rem /W4 - warning level 4
rem /O2 - optimize for speed. better than /Ox, implies /Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy
rem /Gm- - disables minimal rebuild
rem /EHsc - enable ++ excecptions
rem /GS - buffer ovverun cheks
rem /Od - disbale optimizations
set THIRDPARTY_DIR=D:\Projects\thirdparty\vc142-%2\include
set RELEASE_CPPFLAGS=/EHsc /Z7 /Gm- /O2      /Gm-         /I %THIRDPARTY_DIR%
set   DEBUG_CPPFLAGS=/EHsc /Z7 /Gm- /Od /Oy- /GS          /I %THIRDPARTY_DIR%
set RELEASE_DEFINES=/D NDEBUG /D WIN32 /D _WIN32_WINNT=0x0600 /D WIN32_LEAN_AND_MEAN /D _SCL_SECURE_NO_WARNINGS
set   DEBUG_DEFINES=/D _DEBUG /D WIN32 /D _WIN32_WINNT=0x0600 /D WIN32_LEAN_AND_MEAN /D _SCL_SECURE_NO_WARNINGS

copy src\p11_err.h  include
copy src\libp11.h   include

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MT
set LIB_FLAGS=
call :build_lib %libname%-mt-s.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MTd
set LIB_FLAGS=
call :build_lib %libname%-mt-sgd.lib

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MD
set LIB_FLAGS=
call :build_lib %libname%-mt.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MDd
set LIB_FLAGS=
call :build_lib %libname%-mt-gd.lib


set arname=%libname%-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include

rd build include lib /q/s

endlocal
goto :eof


:build_lib
cl /c %FLAGS% %source_dir%\*.c /Fobuild\
lib %LIB_FLAGS%   build\*.obj -out:lib\%1
del build\* /q
goto :eof
