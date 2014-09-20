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
@echo off

:: Display the disclaimer
echo "WARNING: This program can cause irrerepairable damage to your Windows"
echo "installation. By continuing you are assuming any and all risk for any
echo "damage or lost data."
echo ""
echo "IF YOU HAVE NOT DONE SO IT IS HIGHLY RECOMMENDED THAT YOU BACK UP YOUR
echo "SYSTEM DRIVE BEFORE PROCEEDING."
echo ""
set /P answer="Do you want to continue? (Y/N): "
::set proceed=false
::if %answer% eq Y set proceed=true
::if %answer% eq y set proceed=true
::if %proceed% == false(
::	exit /B 0
::)

:: Copy Users and ProgramData
::robocopy /B /E /XJ /SL /COPYALL %1\Users %2\Users
::if %errorlevel% neq 0 (
::	echo "Errors occurred while copying %1\Users. Aborting..."
::	exit /B %errorlevel%
::)
::robocopy /B /E /XJ /SL /COPYALL %1\ProgramData %2\ProgramData
::if %errorlevel% neq 0 (
::	echo "Errors occurred while copying %1\ProgramData. Aborting..."
::	exit /B %errorlevel%
::)
::
:::: Copy all reparse points
cplink /V /R %1 %2 %1\Users %2\Users
if %errorlevel% neq 0 (
	echo "Errors occurred while copying reparse points. Aborting..."
	exit /B %errorlevel%
)
cplink /V /R %1 %2 %1\ProgramData %2\ProgramData
if %errorlevel% neq 0 (
	echo "Errors occurred while copying reparse points. Aborting..."
	exit /B %errorlevel%
)

:: Point of no return
echo "Everything has been copied to %2 and looks good to go."
echo "THIS IS YOUR LAST CHANCE TO CHANGE YOUR MIND."
echo ""
set /P answer="Are you ready to proceed? (Y/N): "
set proceed=false
if %answer% eq "Y" set proceed=true
if %answer% eq "y" set proceed=true
if %proceed% neq "true" (
	exit /B 0
)

:: Remove the old paths
echo "Removing %1\Users..."
::rmdir /S %1\Users
echo "Removing %1\ProgramData..."
::rmdir /S %1\ProgramData
::rmlink "%1\Documents and Settings"

:: Create junctions to the relocated paths
::mklink /D %1\Users %2\Users
::mklink /D %1\ProgramData %2\ProgramData
::mklink /D "%1\Documents and Settings" "%2\Users"

echo "Success!"
