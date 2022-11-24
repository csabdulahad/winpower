:: author: ABDUL AHAD
:: version: 1.0
:: website: http://abdulahad.net

:: THIS SCRIPT ADDS PATH TO THE USER LEVEL ENVIRONMENT VARIABLES.

:: INSTALLATION
:: It is advised to place this file inside "Program Files" under a folder
:: named anything you pefer. Then add the folder path the SYSTEM LEVEL ENVIRONMENT.

:: HOW TO USE
:: Open CMD to the location that you want to add to the path.
:: Type piyon (this will add current CMD path).
:: Or type piyon followed by any path you like warped by dobule quotes.

@echo off

setlocal

if "%~1"=="" (set path_arg=%cd%) else (set path_arg=%~1)

set ok=0
for /f "skip=2 tokens=3*" %%a in ('reg query HKCU\Environment /v PATH') do if [%%b]==[] ( setx PATH "%%~a;%path_arg%" && set ok=1 ) else ( setx PATH "%%~a %%~b;%path_arg%" && set ok=1 )

if "%ok%" == "0" setx PATH "%path_arg%"

:end

endlocal

echo Please visit, http://abdulahad.net :)