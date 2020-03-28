setlocal
rem xercesc helper build script 
set version=3.2.1
set vcver=v141
set vcvars=vc141vars

rem CMP0091 enables CMAKE_MSVC_RUNTIME_LIBRARTY
set cmake_common_flags=-G"NMake Makefiles" -DBUILD_SHARED_LIBS=OFF -Dtranscoder=windows -Dxmlch-type=wchar_t -Dnetwork:BOOL=OFF -DCMAKE_POLICY_DEFAULT_CMP0091=NEW

rem call :build_platform %vcvars% x86
call :build_platform %vcvars% x64

endlocal
goto :eof

:build_platform
setlocal
call %1 %2
echo on 

rd build lib include /q/s > nul
mkdir build lib include
mkdir build\ReleaseDRT build\DebugDRT build\ReleaseSRT build\DebugSRT build\headers

pushd build\ReleaseDRT
cmake ..\.. %cmake_common_flags% -DCMAKE_BUILD_TYPE=RelWithDebInfo && cmake --build .
popd

pushd build\DebugDRT
cmake ..\.. %cmake_common_flags% -DCMAKE_BUILD_TYPE=Debug && cmake --build .
popd

pushd build\ReleaseSRT
cmake ..\.. %cmake_common_flags% -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded && cmake --build .
popd

pushd build\DebugSRT
cmake ..\.. %cmake_common_flags% -DCMAKE_BUILD_TYPE=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug && cmake --build .
popd

rem includes
copy build\ReleaseDRT\src\xerces-c_3.lib lib\xercesc-mt.lib
copy build\DebugDRT\src\xerces-c_3D.lib lib\xercesc-mt-gd.lib
copy build\ReleaseSRT\src\xerces-c_3.lib lib\xercesc-mt-s.lib
copy build\DebugSRT\src\xerces-c_3D.lib lib\xercesc-mt-sgd.lib

pushd build\headers
cmake ..\.. %cmake_common_flags% -DCMAKE_INSTALL_PREFIX=inst && cmake --build . && cmake --install .
popd

robocopy build\headers\inst\include\ include\ /S

rem acrive

set arname=xercesc-%version%-%vcver%-%2.zip
del %arname%
7z a -tzip %arname% lib include 

rem rd build lib include /q/s

endlocal
goto :eof
