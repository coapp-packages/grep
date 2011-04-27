@echo off
setlocal enabledelayedexpansion
set COPKG_VERSION=1.0.0.0

set VERIFY=
set CLEAN=
set BUILD=

FOR %%A IN (%*) DO (
  if /i [%%A] == [clean] set CLEAN=TRUE
  if /i [%%A] == [build] set BUILD=TRUE
  if /i [%%A] == [verify] set VERIFY=TRUE
)
if NOT "%VERIFY%%BUILD%%CLEAN%" == "" goto CONTINUE

:CO_HELP 
echo.
echo CoApp PKG Script %COPKG_VERSION%
echo Copyright (c) Garrett Serack, CoApp Contributors 2010-2011. All rights reserved
echo -------------------------------------------------------------------------------
echo.
echo Usage
echo ===== 
echo     %0 [options]
echo.
echo     where options is one or more of:
echo           build   - builds the product
echo           clean   - removes all files that are not part of the project src
echo           verify  - ensures that the product source matches the built 
echo                     and cleaned
echo.
echo -------------------------------------------------------------------------------
goto FIN

:CONTINUE
if [%CLEAN%] == [TRUE] call :DO_CLEAN
if [%BUILD%] == [TRUE] call :DO_BUILD

if [%VERIFY%] == [TRUE] goto DO_VERIFY
goto FIN
:DO_VERIFY
call :DO_CLEAN
call :DO_BUILD
call :VERIFY_OUTPUTS
if [!SUCCESS!] == [FALSE] goto FIN

call :DO_CLEAN

for /F "usebackq delims==" %%i IN (`cmd /c "git status -s | findstr -v COPKG"`) DO ( 
    set SUCCESS=FALSE
)

if [!SUCCESS!] == [FALSE] goto VERIFY_FAIL
echo.
echo BUILD/CLEAN VERIFY SUCCESSFUL.

goto FIN
:VERIFY_FAIL
echo. 
echo. 
echo ***********************************************************************
echo Verify step not successful.
echo Use git status to identify files that are changed or added that should
echo be cleaned up after the build, and update the DO_CLEAN routine.
echo ***********************************************************************
goto FIN

:VERIFY_OUTPUTS
for /F %%v in (%~dp0\COPKG_OUTPUTS.TXT) do (
    set CURFILE=%%v
    if NOT exist !CURFILE! goto FAILED_VERIFY
)
:DONE_VERIFY
goto :EOF

:FAILED_VERIFY
echo. 
echo. 
echo ***********************************************************************
echo Expected output file %CURFILE% not found.
echo VERIFICATION FAILED.
echo ***********************************************************************
set SUCCESS=FALSE
goto :EOF

:DO_CLEAN
call %~dp0\COPKG_CLEAN.CMD
goto :EOF
 
:DO_BUILD
call %~dp0\COPKG_BUILD.CMD
goto :EOF

:FIN
echo. 
echo Done.