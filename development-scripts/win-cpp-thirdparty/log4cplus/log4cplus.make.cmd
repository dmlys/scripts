set ver=2.0.5
set vcver=vc142
set name=log4cplus

rem call :build_platform x86
call :build_platform x64
goto :eof

:build_platform
setlocal
REM %1 - is plat, like x64, x86

call %vcver%vars %1
rd    lib bin msvc14\bin msvc14\lib /q/s
mkdir lib bin msvc14\bin msvc14\lib

REM ansi dll
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release

robocopy msvc14\bin\%1_debug    bin *.dll *.pdb
robocopy msvc14\bin\%1_release  bin *.dll *.pdb
robocopy msvc14\bin\%1_debug    lib *.lib
robocopy msvc14\bin\%1_release  lib *.lib

REM unicode dll
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;CharacterSet=Unicode
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;CharacterSet=Unicode

robocopy msvc14\bin\%1_debug    bin *.dll *.pdb
robocopy msvc14\bin\%1_release  bin *.dll *.pdb
robocopy msvc14\bin\%1_debug    lib *.lib
robocopy msvc14\bin\%1_release  lib *.lib

REM ansi static
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;ConfigurationType=StaticLibrary;Runtime=Static
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;ConfigurationType=StaticLibrary;Runtime=Static

robocopy msvc14\bin\%1_debug\lib    lib *.lib
robocopy msvc14\bin\%1_release\lib  lib *.lib

msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;ConfigurationType=StaticLibrary
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;ConfigurationType=StaticLibrary

robocopy msvc14\bin\%1_debug\lib    lib *.lib
robocopy msvc14\bin\%1_release\lib  lib *.lib

REM unicode static
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;ConfigurationType=StaticLibrary;Runtime=Static;CharacterSet=Unicode
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;ConfigurationType=StaticLibrary;Runtime=Static;CharacterSet=Unicode

robocopy msvc14\bin\%1_debug\lib    lib *.lib
robocopy msvc14\bin\%1_release\lib  lib *.lib

msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;ConfigurationType=StaticLibrary;CharacterSet=Unicode
msbuild msvc14\log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;ConfigurationType=StaticLibrary;CharacterSet=Unicode

robocopy msvc14\bin\%1_debug\lib    lib *.lib
robocopy msvc14\bin\%1_release\lib  lib *.lib

set arname=%name%-%ver%-%vcver%-%1.zip
7z a -tzip %arname% lib bin include\log4cplus

endlocal
goto :eof
