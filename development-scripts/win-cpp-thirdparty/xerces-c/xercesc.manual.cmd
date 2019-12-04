setlocal
rem fmt build
rem xercesc helper build script 
set version=3.2.2
set vcver=v141
set vcvars=vc141vars
set libname=xercesc
rem set thirdparty_include=C:\Projects\thirdparty\vc14.1-x64\include

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
set RELEASE_CPPFLAGS=/EHsc /Z7 /Gm- /O2 /GL  /Gm-   /I src /I xercesc_manual_config
set   DEBUG_CPPFLAGS=/EHsc /Z7 /Gm- /Od /Oy- /GS    /I src /I xercesc_manual_config
set RELEASE_DEFINES=/D NDEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _SCL_SECURE_NO_WARNINGS /D _CRT_SECURE_NO_DEPRECATE /D XERCES_BUILDING_LIBRARY=1 /D _THREAD_SAFE=1 /D HAVE_CONFIG_H=1
set   DEBUG_DEFINES=/D _DEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _SCL_SECURE_NO_WARNINGS /D _CRT_SECURE_NO_DEPRECATE /D XERCES_BUILDING_LIBRARY=1 /D _THREAD_SAFE=1 /D HAVE_CONFIG_H=1

copy xercesc_manual_config\XercesVersion.hpp            src\xercesc\util\XercesVersion.hpp
copy xercesc_manual_config\Xerces_autoconf_config.hpp   src\xercesc\util\Xerces_autoconf_config.hpp

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MT
set LIB_FLAGS=/LTCG
call :build_lib %libname%-mt-s.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MTd
set LIB_FLAGS=
call :build_lib %libname%-mt-sgd.lib

set FLAGS=%RELEASE_DEFINES% %RELEASE_CPPFLAGS% /MD
set LIB_FLAGS=/LTCG
call :build_lib %libname%-mt.lib

set FLAGS=%DEBUG_DEFINES% %DEBUG_CPPFLAGS% /MDd
set LIB_FLAGS=
call :build_lib %libname%-mt-gd.lib

robocopy src\xercesc\ include\xercesc\ *.hpp *.c /S   /XD NSS /XD FileManagers /XD MsgLoaders /XD MutexManagers /XD NetAccessors /XD Transcoders
robocopy src\xercesc\util\FileManagers\        include\xercesc\util\FileManagers\        WindowsFileMgr.hpp /S
robocopy src\xercesc\util\MsgLoaders\InMemory\ include\xercesc\util\MsgLoaders\InMemory\              *.hpp /S
robocopy src\xercesc\util\MutexManagers\       include\xercesc\util\MutexManagers\   StdMutexMgr.hpp WindowsMutexMgr.hpp /S
robocopy src\xercesc\util\Transcoders\Win32    include\xercesc\util\Transcoders\Win32            *.hpp /S

set arname=%libname%-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include

rem rd include build lib /q/s

endlocal
goto :eof


:build_lib
cl /c %FLAGS% /Fobuild\ ^
  src\xercesc\dom\*.cpp src\xercesc\dom\impl\*.cpp ^
  src\xercesc\framework\*.cpp src\xercesc\framework\psvi\*.cpp src\xercesc\internal\*.cpp ^
  src\xercesc\parsers\*.cpp src\xercesc\sax\*.cpp src\xercesc\sax2\*.cpp ^
  src\xercesc\util\*.cpp src\xercesc\util\FileManagers\WindowsFileMgr.cpp src\xercesc\util\MsgLoaders\InMemory\*.cpp src\xercesc\util\MutexManagers\StdMutexMgr.cpp src\xercesc\util\*.cpp src\xercesc\util\regx\*.cpp src\xercesc\util\Transcoders\Win32\*.cpp ^
  src\xercesc\validators\common\*.cpp src\xercesc\validators\datatype\*.cpp src\xercesc\validators\DTD\*.cpp src\xercesc\validators\schema\*.cpp src\xercesc\validators\schema\identity\*.cpp ^
  src\xercesc\xinclude\*.cpp

lib %LIB_FLAGS%   build\*.obj -out:lib\%1
del build\* /q
goto :eof
