
@echo off

REM If user directly clicks on cmd file then pass no as consent
set "cona=%~1"
if "%cona%"=="" set "cona=n"

powershell -Command "$xp = Get-ExecutionPolicy; Set-ExecutionPolicy Bypass CurrentUser; Start-Process powershell -Verb RunAs '-File c:/winpower/ps/wp_setup.ps1 %cona%', $xp"
