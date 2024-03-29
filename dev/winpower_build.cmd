@echo off

REM This scrips build the WinPower_X.X.X.exe file under download
REM folder. It first asks for the version number then modifies
REM the in-file WinPower version and then invokes ISCC software
REM to build

cd "c:/winpower_dev/dev/build"

REM Get the version for this build
:input
set /p "version=WinPower version: "

if "%version%"=="" (
    echo Version is missing
    goto input
) else (
    REM First update the in-file WinPower version
    powershell -File build_winpower.ps1 %version%

    REM Start the build process with specified version
    REM add the following at the end of the command to suppress the log: '> NUL'
    ISCC.exe /D"version=%version%" "winpower.iss"
)

REM Remove both the zip and exe WinPower from the download folder
powershell -Command "Set-Location 'c:/winpower_dev/download/'; Remove-Item -Force -Path 'WinPower.exe'; Remove-Item -Force -Path 'WinPower.zip'"

REM Make a copy of the winpower exe file and place it on download folder for download
set "fileName=WinPower_%version%.exe"
powershell -Command "Set-Location 'c:/winpower_dev'; Copy-Item -Path 'download/installer/%fileName%' -Destination 'download/WinPower.exe';"

REM Make a zip file for the winpower source
set "zipName=WinPower_%version%.zip"
powershell -Command "Set-Location 'c:/winpower_dev'; Compress-Archive -Update -Path 'winpower' -Destination 'download/zip/%zipName%'; Copy-Item -Force -Path 'download/zip/%zipName%' -Destination 'download/WinPower.zip'"