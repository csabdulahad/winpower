REM This scrips build the WinPower_X.X.X.exe file under download
REM folder. It first asks for the version number then modifies
REM the in-file WinPower version and then invokes ISCC software
REM to build

@echo off

cd "c:/winpower_dev/dev/build"

REM Get the version for this build
:input
set /p "version=WinPower version: "

if "%version%"=="" (
    echo Version is missing
    goto input
) else (
    REM First update the in-file WinPower version
    powershell -File update_setup_file_ver.ps1 %version%

    REM Start the build process with specified version
    REM add the following at the end of the command to suppress the log: '> NUL'
    ISCC.exe /D"version=%version%" "winpower.iss"
)
