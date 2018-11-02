@echo %path% | findstr /L "%qtdir%\bin" > nul
@if %ERRORLEVEL% gtr 0 set path=%path%;%qtdir%\bin