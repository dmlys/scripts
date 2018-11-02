@echo off
rem /Z7 - debug info
rem /W4 - warning level 4
rem /O2 - optimize for speed. better than /Ox, implies /Og /Oi /Ot /Oy /Ob2 /Gs /GF /Gy
rem /Gm- - disables minimal rebuild
rem /EHsc - enable ++ excecptions
rem /MD - link with msvcrt.lib(dynamic library dll)
rem /GS - buffer ovverun cheks
rem /Od - disbale optimizations

rem release /EHsc /GS /Z7 /W4 /O2 /Gm-       /MD    /D NDEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _MBCS /fp:precise /Zc:wchar_t /Zc:forScope 
rem debug /EHsc /GS /Z7 /W4 /Od /Oy- /Gm-    /MDd   /D _DEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _MBCS /fp:precise /Zc:wchar_t /Zc:forScope 

set RELEASE_CPPFALGS=/EHsc /GS /Z7 /W4 /O2 /Gm-
set   DEBUG_CPPFALGS=/EHsc /GS /Z7 /W4 /Od /Oy- /Gm-
set RELEASE_DEFINES=/D NDEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _MBCS
set   DEBUG_DEFINES=/D _DEBUG /D WIN32 /D _WIN32_WINNT=0x501 /D _MBCS