
@echo off

powershell -Command "if ((Get-ExecutionPolicy) -ne \"RemoteSigned\") { exit 1; }"
if %errorlevel% equ 1 (
    echo WinPower does not have enough permission to run.

    setlocal enabledelayedexpansion
    set /p "input=Do you want to run wp setup? (y/n): "
    if "!input!" equ "y" (
        call c:/winpower/cmd/wp_setup.cmd
    )
    exit
)

set "a=%*"
powershell -File "c:/winpower/ps/wp.ps1" "ox" %a%
