
@echo off

REM update version as test and make cmd files
powershell -File "c:/winpower_dev/dev/build/build_winpower.ps1" "TEST BUILD"

REM It makes a development copy of WinPower to C directory for testing
powershell -Command "Set-Location 'c:/winpower_dev/'; Copy-Item -Force -Recurse -Path 'winpower' -Destination 'c:/'"
