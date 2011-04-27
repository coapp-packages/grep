@echo off

REM builds from the Visual Studio command prompt just fine:
cl /O2 /Tc *.c /DHAVE_STRERROR /link /out:grep.exe

