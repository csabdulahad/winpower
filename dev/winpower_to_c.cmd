REM This script just copies the winpower from development folder to
REM the final-running c:/winpower folder for making testing easier

@echo off

REM It makes a development copy of WinPower to C directory for testing
powershell.exe -Command "Copy-Item -Force -Recurse -Path 'winpower' -Destination 'c:/'"

Rem Now run the setup.ps1 script
winpower/setup.cmd