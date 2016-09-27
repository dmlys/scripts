setlocal
call config.cmd
set include_dir=%boost_dir%/boost

robocopy %include_dir% %deploy_dir%\x86\include\boost /E /MIR
robocopy %stage_dir86%\lib %deploy_dir%\x86\lib /E /MIR

robocopy %include_dir% %deploy_dir%\x64\include\boost /E /MIR
robocopy %stage_dir64%\lib %deploy_dir%\x64\lib /E /MIR

pushd %deploy_dir%\x86
7z a %boost_dir%-vc14-x86.7z .\
popd

pushd %deploy_dir%\x64
7z a %boost_dir%-vc14-x64.7z .\
popd

move %deploy_dir%\x86\%boost_dir%-vc14-x86.7z .
move %deploy_dir%\x64\%boost_dir%-vc14-x64.7z .