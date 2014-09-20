:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyright (c) 2014, Jean-Philippe Steinmetz
:: All rights reserved.
:: 
:: Redistribution and use in source and binary forms, with or without
:: modification, are permitted provided that the following conditions are met:
:: 
:: * Redistributions of source code must retain the above copyright notice, this
::   list of conditions and the following disclaimer.
:: 
:: * Redistributions in binary form must reproduce the above copyright notice,
::   this list of conditions and the following disclaimer in the documentation
::   and/or other materials provided with the distribution.
:: 
:: THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
:: AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
:: IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
:: DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
:: FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
:: DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
:: SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
:: CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
:: OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
:: OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Note that this script is intended to be run from the Windows Pre Installation
:: Environment (e.g. Windows Installer). As a result, the source and destination
:: drives are not expected to follow the traditional pattern of C:, D:, etc.
::
:: Usage: MoveUserData.bat <SrcDrive> <DestDrive> [RealSrcDrive] [RealDestDrive]
::
:: Example: MoveUserData.bat F: E: C: D:
::   Moves the Users and ProgramData folders found on drive F: to drive E:. Rewrites
::   all junctions and symlinks pointing to C: to D:.
::
:: Arguments
:: %1 - <SrcDrive> - The source drive to copy user data from (e.g. F:)
:: %2 - <DestDrive> - The destination drive to copy user data to
::		(e.g. E:)
:: %3 - <RealSrcDrive> - The drive letter of the source when running live
::		in Windows. This argument is optional, if not specified will default
::		to C:
:: %4 - <RealDestDrive> - The drive letter of the destination when
::      running live in Windows. This argument is optional, if not specified
::		will default to D:
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

:: Variables
set SrcDrive=%1
set DestDrive=%2
if [%3] == [] (
	set RealSrcDrive=C:
) else (
	set RealSrcDrive=%3
)
if [%4] == [] (
	set RealDestDrive=D:
) else (
	set RealDestDrive=%4
)

:: Validate required arguments
if not exist %SrcDrive% (
	echo %SrcDrive% does not exist.
	exit /B 1
)
if not exist %DestDrive% (
	echo %DestDrive% does not exist.
	exit /B 1
)

:: Display the disclaimer
echo WARNING: This program can cause irrerepairable damage to your Windows
echo installation. By continuing you are assuming any and all risk for any
echo damage or lost data.
echo.
echo IF YOU HAVE NOT DONE SO IT IS HIGHLY RECOMMENDED THAT YOU BACK UP YOUR
echo SYSTEM DRIVE BEFORE PROCEEDING.
echo.
echo Source: %SrcDrive% [%RealSrcDrive%]
echo Destination: %DestDrive% [%RealDestDrive%]
echo.
set /P answer="Do you want to continue? (Y/N): "
set proceed=false
if %answer% == Y set proceed=true
if %answer% == y set proceed=true
if %proceed% == false (
	exit /B 0
)

:: Copy Users and ProgramData
robocopy /B /E /XJ /SL /COPYALL %SrcDrive%\Users %DestDrive%\Users
if %errorlevel% neq 0 (
	echo "Errors occurred while copying %SrcDrive%\Users. Aborting..."
	exit /B %errorlevel%
)
robocopy /B /E /XJ /SL /COPYALL %SrcDrive%\ProgramData %DestDrive%\ProgramData
if %errorlevel% neq 0 (
	echo "Errors occurred while copying %SrcDrive%\ProgramData. Aborting..."
	exit /B %errorlevel%
)

:: Copy and rewrite all reparse points
cplink /V /R %RealSrcDrive% %RealDestDrive% %SrcDrive%\Users %DestDrive%\Users
if %errorlevel% neq 0 (
	echo Errors occurred while copying reparse points. Aborting...
	exit /B %errorlevel%
)
cplink /V /R %RealSrcDrive% %RealDestDrive% %SrcDrive%\ProgramData %DestDrive%\ProgramData
if %errorlevel% neq 0 (
	echo Errors occurred while copying reparse points. Aborting...
	exit /B %errorlevel%
)

:: Point of no return
echo Everything has been copied to %DestDrive% and looks good to go.
echo THIS IS YOUR LAST CHANCE TO CHANGE YOUR MIND.
echo.
set /P answer="Are you ready to proceed? (Y/N): "
set proceed=false
if %answer% == Y set proceed=true
if %answer% == y set proceed=true
if %proceed% == false (
	exit /B 0
)

:: Remove the old paths
echo Removing %SrcDrive%\Users...
rmdir /S /Q %SrcDrive%\Users
echo Removing %SrcDrive%\ProgramData...
rmdir /S /Q %SrcDrive%\ProgramData
rmlink "%SrcDrive%\Documents and Settings"

:: Create junctions to the relocated paths
mklink /D %SrcDrive%\Users %RealDestDrive%\Users
mklink /D %SrcDrive%\ProgramData %RealDestDrive%\ProgramData
mklink /D "%SrcDrive%\Documents and Settings" "%RealDestDrive%\Users"

echo Success!
