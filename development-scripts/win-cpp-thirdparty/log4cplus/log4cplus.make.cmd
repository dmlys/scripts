setlocal
call log4cplus.config.cmd
call vc141vars x64

call log4cplus.build.cmd x64
call log4cplus.zip.cmd x64
endlocal

rem setlocal
rem call log4cplus.config.cmd x86
rem call vc141vars x86
rem 
rem call log4cplus.build.cmd x86
rem call log4cplus.zip.cmd x86
rem endlocal
