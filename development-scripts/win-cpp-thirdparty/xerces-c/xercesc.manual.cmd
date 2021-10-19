setlocal
rem fmt build
rem xercesc helper build script 
set version=3.2.3
set vcver=v142
set vcvars=vc142vars
set libname=xercesc
rem set thirdparty_include=C:\Projects\thirdparty\vc14.1-x64\include

REM !!!!! IMPORTANT !!!!!
REM NOTE FOR DLL, in client code you should define XERCES_DLL_EXPORT, but not XERCES_BUILDING_LIBRARY
REM XERCES_DLL_EXPORT will mark classes with __declspec(dllimport), this is important for some class static datatype
REM otherwise you would get liner errors

rem /Z7 - debug info
rem /W4 - warning level 4
rem /O2 - optimize for speed. better than /Ox, implies /Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy
rem /Gm- - disables minimal rebuild
rem /EHsc - enable ++ excecptions
rem /GS - buffer ovverun cheks
rem /Od - disbale optimizations
set RELEASE_CPPFLAGS=/EHsc /Z7 /Gm- /O2      /Gm-   /I src /I xercesc_manual_config
set   DEBUG_CPPFLAGS=/EHsc /Z7 /Gm- /Od /Oy- /GS    /I src /I xercesc_manual_config
set RELEASE_DEFINES=/D NDEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _SCL_SECURE_NO_WARNINGS /D _CRT_SECURE_NO_DEPRECATE /D XERCES_BUILDING_LIBRARY=1 /D _THREAD_SAFE=1 /D HAVE_CONFIG_H=1
set   DEBUG_DEFINES=/D _DEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _SCL_SECURE_NO_WARNINGS /D _CRT_SECURE_NO_DEPRECATE /D XERCES_BUILDING_LIBRARY=1 /D _THREAD_SAFE=1 /D HAVE_CONFIG_H=1
set RC_DEFINES=-DXERCES_DLL_NAME=\"%libname%_3_2.dll\0\"

call :build_platform %vcvars% x86
call :build_platform %vcvars% x64

endlocal
goto :eof

rem %1 - %vcver%vars %2 - platform
:build_platform
setlocal
call %1 %2
echo on

rd include build bin lib /q/s > nul
mkdir include build bin lib


copy xercesc_manual_config\XercesVersion.hpp            src\xercesc\util\XercesVersion.hpp
copy xercesc_manual_config\Xerces_autoconf_config.hpp   src\xercesc\util\Xerces_autoconf_config.hpp

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

set FLAGS=%RELEASE_DEFINES% -DXERCES_DLL_EXPORT %RELEASE_CPPFLAGS% /MD
set LINK_FLAGS=
call :build_dll %libname%_3.lib %libname%_3_2.dll

set FLAGS=%DEBUG_DEFINES% -DXERCES_DLL_EXPORT %DEBUG_CPPFLAGS% /MDd
set LINK_FLAGS=
call :build_dll %libname%_3.lib %libname%_3_2.dll

robocopy src\xercesc\ include\xercesc\ *.hpp *.c /S   /XD NSS /XD FileManagers /XD MsgLoaders /XD MutexManagers /XD NetAccessors /XD Transcoders
robocopy src\xercesc\util\FileManagers\        include\xercesc\util\FileManagers\        WindowsFileMgr.hpp /S
robocopy src\xercesc\util\MsgLoaders\InMemory\ include\xercesc\util\MsgLoaders\InMemory\              *.hpp /S
robocopy src\xercesc\util\MutexManagers\       include\xercesc\util\MutexManagers\          StdMutexMgr.hpp WindowsMutexMgr.hpp /S
robocopy src\xercesc\util\Transcoders\Win32    include\xercesc\util\Transcoders\Win32                 *.hpp /S

set arname=%libname%-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib bin include

rd include build bin lib /q/s

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

:build_dll
cl /c %FLAGS% /Fobuild\ ^
  src\xercesc\dom\*.cpp src\xercesc\dom\impl\*.cpp ^
  src\xercesc\framework\*.cpp src\xercesc\framework\psvi\*.cpp src\xercesc\internal\*.cpp ^
  src\xercesc\parsers\*.cpp src\xercesc\sax\*.cpp src\xercesc\sax2\*.cpp ^
  src\xercesc\util\*.cpp src\xercesc\util\FileManagers\WindowsFileMgr.cpp src\xercesc\util\MsgLoaders\InMemory\*.cpp src\xercesc\util\MutexManagers\StdMutexMgr.cpp src\xercesc\util\*.cpp src\xercesc\util\regx\*.cpp src\xercesc\util\Transcoders\Win32\*.cpp ^
  src\xercesc\validators\common\*.cpp src\xercesc\validators\datatype\*.cpp src\xercesc\validators\DTD\*.cpp src\xercesc\validators\schema\*.cpp src\xercesc\validators\schema\identity\*.cpp ^
  src\xercesc\xinclude\*.cpp

rc %RC_DEFINES% /fo build\version.rc.res xercesc_manual_config\version.rc

rem /version:0.0 /machine:X86
link %LINK_FLAGS% /dll /debug /implib:lib\%1 /out:bin\%2 build\*.obj Advapi32.lib build\version.rc.res
del bin\*.ilk
del lib\*.exp
del build\* /q
goto :eof



