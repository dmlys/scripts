setlocal
rem cppformat build
set source_dir=cppformat
set version=2.1
set vcver=vc14

call :build_platform %vcver%vars x86
call :build_platform %vcver%vars x64

endlocal
goto :eof

rem %1 - %vcver%vars %2 - platform
:build_platform
setlocal
call %1 %2

rd build lib include /q/s > nul
mkdir build lib include\cppformat
copy %source_dir%\*.h include\cppformat

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
call :build_lib cppformat-mt-s.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MTd
call :build_lib cppformat-mt-sgd.lib

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MD
call :build_lib cppformat-mt.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MDd
call :build_lib cppformat-mt-gd.lib


set arname=cppformat-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include

rd build lib include /q/s

endlocal
goto :eof


:build_lib
cl /c %FLAGS% %source_dir%\*.cc /Fobuild\
lib build\*.obj -out:lib\%1
del build\* /q
goto :eof

