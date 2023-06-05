
Set-Location "c:/winpower_dev/winpower";

$setupFile = "lib/func.ps1";
$ver = $args[0];

# Read the content of the script file
$setupCode = Get-Content -Path $setupFile

# Find and replace the variable assignment line in the script content
$setupCode = $setupCode -replace '\$winVer = .+', "`$winVer = '$ver'"

# Write the updated content back to the script file
$setupCode | Set-Content -Path $setupFile

# generate cmd files for ps files

$files = Get-ChildItem -Path "ps" -File;
foreach ($file in $files) {
    $skipFiles = 'wp_setup.ps1', 'wp.ps1';
    if ($skipFiles.Contains($file.Name)) { continue; }

    $path = 'cmd/' + $file.Name.Replace('ps1', 'cmd');
    $cmdCode = '
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
powershell -File "c:/winpower/ps/wp.ps1" "' + $file.Name.Replace('.ps1', '') + '" %a%';

    $cmdCode | Set-Content -Path $path;

}