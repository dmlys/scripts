setlocal
rem xml-security-c helper build script 
set version=2.0.2
set vcver=v142
set vcvars=vc142vars
set libname=xml-security

REM call :build_platform %vcvars% x86
call :build_platform %vcvars% x64

endlocal
goto :eof

rem %1 - %vcver%vars %2 - platform
:build_platform
setlocal
call %1 %2
echo on

rd include build lib /q/s > nul
mkdir include build lib

rem /Z7 - debug info
rem /W4 - warning level 4
rem /O2 - optimize for speed. better than /Ox, implies /Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy
rem /Gm- - disables minimal rebuild
rem /EHsc - enable ++ excecptions
rem /GS - buffer ovverun cheks
rem /Od - disbale optimizations
set thirdparty_include=C:\Projects\thirdparty\vc14.2-%2\include
set RELEASE_CPPFLAGS=/EHsc /Z7 /Gm- /O2      /Gm-   /I . /I %thirdparty_include%
set   DEBUG_CPPFLAGS=/EHsc /Z7 /Gm- /Od /Oy- /GS    /I . /I %thirdparty_include%
set RELEASE_DEFINES=/D NDEBUG /D WIN32 /D _WIN32_WINNT=0x0A00 /D _SCL_SECURE_NO_WARNINGS /D _CRT_SECURE_NO_DEPRECATE                      /D XSEC_BUILDING_LIBRARY /D XSEC_HAVE_OPENSSL /D XSEC_HAVE_WINCAPI
set   DEBUG_DEFINES=/D _DEBUG /D WIN32 /D _WIN32_WINNT=0x0A00 /D _SCL_SECURE_NO_WARNINGS /D _CRT_SECURE_NO_DEPRECATE /D _XSEC_DO_MEMDEBUG /D XSEC_BUILDING_LIBRARY /D XSEC_HAVE_OPENSSL /D XSEC_HAVE_WINCAPI
rem you may need to remove 

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

rem robocopy xsec\ include\xsec\ *.hpp /S /XD xkms /XD NSS /XD unixutils
robocopy xsec\ include\xsec\ *.hpp /S          /XD NSS /XD unixutils

set arname=%libname%-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include

rem rd include build lib /q/s

endlocal
goto :eof


:build_lib
cl /c %FLAGS% /Fobuild\ xsec\canon\*.cpp xsec\dsig\*.cpp xsec\enc\*.cpp xsec\enc\OpenSSL\*.cpp xsec\enc\WinCAPI\*.cpp xsec\enc\XSCrypt\*.cpp xsec\framework\*.cpp xsec\transformers\*.cpp xsec\utils\*.cpp xsec\xenc\*.cpp xsec\xenc\impl\*.cpp
lib %LIB_FLAGS%   build\*.obj -out:lib\%1
del build\* /q
goto :eof
