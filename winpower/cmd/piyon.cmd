@echo off


REM Figure out if we have any path passed-in to set
set "argPath=%~1"
if "%argPath%"=="" set "argPath=%CD%"


powershell -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-File \"c:/winpower/ps/piyon.ps1\" \"%argPath%\"'"
