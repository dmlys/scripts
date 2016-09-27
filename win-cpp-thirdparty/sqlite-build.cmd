setlocal
rem sqlite build
set sqlite_dir=sqlite-amalgamation-3081101
set sqlite_ver=3.8.11.1
set vcver=vc14

call :build_platform %vcver%vars x86
call :build_platform %vcver%vars x64

endlocal
goto :eof


:build_platform
setlocal
call %1 %2

rd build lib bin include /q/s
mkdir build lib bin include
copy %sqlite_dir%\*.h include

rem /Z7 - debug info
rem /W4 - warning level 4
rem /O2 - optimize for speed. better than /Ox, implies /Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy
rem /Gm- - disables minimal rebuild
rem /EHsc - enable ++ excecptions
rem /GS - buffer ovverun cheks
rem /Od - disbale optimizations
set CPPFLAGS=/O2 /GF /Gy /Gm-
set DEFINES=/D NDEBUG /D _WINDOWS /D NO_TCL /D _CRT_SECURE_NO_DEPRECATE
set DEFINES=/D SQLITE_ENABLE_COLUMN_METADATA /D SQLITE_ENABLE_RTREE %DEFINES%

set FLAGS=%DEFINES% %CPPFLAGS% /MT /GL /Z7
call :build_lib sqlite3-mt-s.lib

set FLAGS=%DEFINES% %CPPFLAGS% /MTd /Z7
call :build_lib sqlite3-mt-sgd.lib

set FLAGS=%DEFINES% %CPPFLAGS% /MD /GL /Z7
call :build_lib sqlite3-mt.lib

set FLAGS=%DEFINES% %CPPFLAGS% /MDd /Z7
call :build_lib sqlite3-mt-gd.lib

set FLAGS=%DEFINES% %CPPFLAGS% /MD /Zi
call :build_dll sqlite3.dll

set FLAGS=%DEFINES% %CPPFLAGS% /MT /GL
cl %sqlite_dir%\sqlite3.c %sqlite_dir%\shell.c /Fobuild\ /Fdbuild\ /Febin\sqlite3.exe
del build\* /q

set arname=sqlite-%sqlite_ver%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include bin

endlocal
goto :eof


:build_lib
cl /c %FLAGS% %sqlite_dir%\sqlite3.c /Fobuild\
lib build\sqlite3.obj -out:lib\%1
del build\* /q
goto :eof


:build_dll
cl /LD %FLAGS% %sqlite_dir%\sqlite3.c /Fobuild\ /Fdbuild\ %sqlite_dir%\sqlite3.def /Febuild\%1
move build\%~n1.dll bin
move build\%~n1.pdb bin
move build\%~n1.lib lib
del build\* /q
goto :eof
