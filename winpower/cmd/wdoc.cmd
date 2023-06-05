@echo off

powershell -Command "function HmWrite([string] $msg, [string]$color, [boolean]$break=$true) { if ($color -eq '') { $color = (Get-Host).UI.RawUI.ForegroundColor; if ($color -eq -1) { $color = 'Gray'; } } $msg = [System.Net.WebUtility]::HtmlDecode($msg); if ($break) { Write-Host $msg -ForegroundColor $color; } else { Write-Host $msg -ForegroundColor $color -NoNewline; } } Write-Host \"`nChecking WinPower installation...`n\"; function WriteMsg([boolean]$result, [string] $msg) {if ($result) { $s = \"^&#9989;\"; } else { $s = \"^&#9940;\"; } $txt = \"$s $msg\"; HmWrite $s Gray $false; HmWrite \"$msg\"; if (-not $result) { HmWrite \"`nType \"\"wp_setup\"\" or reinstall winpower\" DarkYellow; exit 1; } } WriteMsg (Test-Path c:/winpower) \" WinPower installation directory\"; WriteMsg ((Get-ExecutionPolicy) -eq \"RemoteSigned\") \" Execution policy privilege\"; HmWrite \"`nWinPower is ready with \" Cyan $false; HmWrite \"^&#9889;`n\" Yellow"

if %errorlevel% equ 1 (
    setlocal enabledelayedexpansion
    set /p "input=Do you want to run wp setup now? (y/n): "
    if "!input!" equ "y" (
        call c:/winpower/cmd/wp_setup.cmd
    )
)