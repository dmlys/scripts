setlocal
call config.cmd
set thirdparty_dir=D:\Projects\thirdparty

robocopy %boost_dir%/boost %thirdparty_dir%\vc14-x86\include\boost /S
robocopy %boost_dir%/boost %thirdparty_dir%\vc14-x64\include\boost /S

robocopy %stage_dir86%/lib %thirdparty_dir%\vc14-x86\lib *.lib
robocopy %stage_dir64%/lib %thirdparty_dir%\vc14-x64\lib *.lib