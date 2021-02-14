set vcver=14.1
set toolset=%vcver%
::set toolset=%vcver%.0
set boost_dir=boost_1_74_0
set thirdparty_dir=D:\Projects\thirdparty

set stage_dir86=%boost_dir%-lib-x86
set stage_dir64=%boost_dir%-lib-x64
set deploy_dir=deploy

if "%1" == ""          goto build
if "%1" == "build"     goto build
if "%1" == "install"   goto install
if "%1" == "deploy"    goto deploy

rem May want to adjust supported compiller version in: boost\config\compiler\visualc.hpp

:build
pushd %boost_dir%
b2 stage --stagedir=..\%stage_dir86% --build-dir=..\boost-build --abbreviate-paths runtime-link=static,shared address-model=32 architecture=x86 -j4
b2 stage --stagedir=..\%stage_dir64% --build-dir=..\boost-build --abbreviate-paths runtime-link=static,shared address-model=64 architecture=x86 -j4
popd
goto :eof

:install
robocopy %boost_dir%/boost %thirdparty_dir%\vc%vcver%-x86\include\boost /S
robocopy %boost_dir%/boost %thirdparty_dir%\vc%vcver%-x64\include\boost /S

robocopy %stage_dir86%/lib %thirdparty_dir%\vc%vcver%-x86\lib *.lib
robocopy %stage_dir64%/lib %thirdparty_dir%\vc%vcver%-x64\lib *.lib

goto :eof

:deploy

::del %deploy_dir%\x86\include\boost %deploy_dir%\x86\lib
rd /q/s %deploy_dir%
mkdir %deploy_dir%\x86\include
mkdir %deploy_dir%\x64\include

mklink /D %deploy_dir%\x86\include\boost %~dp0%boost_dir%\boost
mklink /D %deploy_dir%\x86\lib           %~dp0%stage_dir86%\lib
::robocopy %boost_dir%/boost   %deploy_dir%\x86\include\boost /E /MIR
::robocopy %stage_dir86%\lib   %deploy_dir%\x86\lib           /E /MIR

mklink /D %deploy_dir%\x64\include\boost %~dp0%boost_dir%\boost
mklink /D %deploy_dir%\x64\lib           %~dp0%stage_dir64%\lib
::robocopy %boost_dir%/boost   %deploy_dir%\x64\include\boost /E /MIR
::robocopy %stage_dir64%\lib   %deploy_dir%\x64\lib           /E /MIR

pushd %deploy_dir%\x86
7z a %boost_dir%-vc%vcver%-x86.7z .\
popd

pushd %deploy_dir%\x64
7z a %boost_dir%-vc%vcver%-x64.7z .\
popd

move %deploy_dir%\x86\%boost_dir%-vc%vcver%-x86.7z .
move %deploy_dir%\x64\%boost_dir%-vc%vcver%-x64.7z .

goto :eof
