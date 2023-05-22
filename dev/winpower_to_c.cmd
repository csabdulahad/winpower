REM This script just copies the winpower from development folder to
REM the final-running c:/winpower folder for making testing easier

@echo off

REM It makes a development copy of WinPower to C directory for testing
powershell -Command "Copy-Item -Force -Recurse -Path 'winpower' -Destination 'c:/'"

REM Ask for whether to run winpower setup script
set /p "setup=Run setup? (y/n) : "
if "%setup%"=="y" (
    Rem Now run the setup.ps1 script
    "winpower/setup.cmd"
)