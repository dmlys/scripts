setlocal
call log4cplus.config.cmd
call vc14vars x64

call log4cplus.build.cmd x64
call log4cplus.zip.cmd x64
endlocal

setlocal
call log4cplus.config.cmd x86
call vc14vars x86

call log4cplus.build.cmd x86
call log4cplus.zip.cmd x86
endlocal
