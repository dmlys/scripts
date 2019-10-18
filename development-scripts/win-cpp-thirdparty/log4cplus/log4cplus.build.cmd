rd bin lib /q/s
mkdir bin lib 

REM %1 - is plat, like x64, x86

REM ansi dll
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release

robocopy bin\%1_debug bin *.dll *.pdb
robocopy bin\%1_release  bin *.dll *.pdb
robocopy bin\%1_debug lib *.lib
robocopy bin\%1_release lib *.lib

REM unicode dll
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;CharacterSet=Unicode
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;CharacterSet=Unicode

robocopy bin\%1_debug bin *.dll *.pdb
robocopy bin\%1_release  bin *.dll *.pdb
robocopy bin\%1_debug lib *.lib
robocopy bin\%1_release lib *.lib

REM ansi static
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;ConfigurationType=StaticLibrary;Runtime=Static
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;ConfigurationType=StaticLibrary;Runtime=Static

robocopy bin\%1_debug\lib lib *.lib
robocopy bin\%1_release\lib lib *.lib

REM unicode static
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Debug;ConfigurationType=StaticLibrary;Runtime=Static;CharacterSet=Unicode
msbuild log4cplus.manual.vcxproj /t:rebuild /p:configuration=Release;ConfigurationType=StaticLibrary;Runtime=Static;CharacterSet=Unicode

robocopy bin\%1_debug\lib lib *.lib
robocopy bin\%1_release\lib lib *.lib
