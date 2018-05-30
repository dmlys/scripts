setlocal
rem fmt build
set source_dir=src
set libname=fmt
set version=5.0.0
set vcver=vc14.1
set vcvars=vc141vars

call :build_platform %vcvars% x86
call :build_platform %vcvars% x64

endlocal
goto :eof

rem %1 - %vcver%vars %2 - platform
:build_platform
setlocal
call %1 %2

rd build lib /q/s > nul
mkdir build lib

rem /Z7 - debug info
rem /W4 - warning level 4
rem /O2 - optimize for speed. better than /Ox, implies /Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy
rem /Gm- - disables minimal rebuild
rem /EHsc - enable ++ excecptions
rem /GS - buffer ovverun cheks
rem /Od - disbale optimizations
set RELEASE_CPPFLAGS=/EHsc /Z7 /Gm- /O2 /GL  /Gm-         /I include
set   DEBUG_CPPFLAGS=/EHsc /Z7 /Gm- /Od /Oy- /GS          /I include
set RELEASE_DEFINES=/D NDEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _SCL_SECURE_NO_WARNINGS
set   DEBUG_DEFINES=/D _DEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _SCL_SECURE_NO_WARNINGS

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MT
set LIB_FLAGS=/LTCG
call :build_lib lib%libname%-mt-s.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MTd
set LIB_FLAGS=
call :build_lib lib%libname%-mt-sgd.lib

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MD
set LIB_FLAGS=/LTCG
call :build_lib lib%libname%-mt.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MDd
set LIB_FLAGS=
call :build_lib lib%libname%-mt-gd.lib


set arname=%libname%-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include

rd build lib /q/s

endlocal
goto :eof


:build_lib
cl /c %FLAGS% %source_dir%\*.cc /Fobuild\
lib %LIB_FLAGS%   build\*.obj -out:lib\%1
del build\* /q
goto :eof
