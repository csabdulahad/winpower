# Include the library functions
. "c:/winpower/lib/func.ps1";

function OpenPWD {
    $clear = Read-Host "Open PWD instad? (y/n)";
    if ($clear -ieq 'y') { return Get-Location; }
    else { Throw ""; }
}

try {

    # Get the path from the clipboard
    $path = Get-Clipboard;
    if ($null -eq $path) {
        $path = Get-Location;
    }


    # Replace any backslash with forward slash
    $path = $path.Replace('\', '/');


    # Make sure the path doesn't have any illegal characters
    $pattern = '[*?"<>|]';
    if ($path -match $pattern) {
        Highlight "Illegal characters found: $path";
        $path = OpenPWD;
    }


    # Check it the path is valid
    if (-Not (Test-Path -Path $path)) {
        Highlight "Path doesn't exist: $path";
        $path = OpenPWD;
    }


    # If it is a file path then load its parent dir
    if ((Test-Path -Path $path -PathType Leaf)) {
        $path = Split-Path -Path $path -Parent;
    }


    # Start explorer with the path
    Start-Process $path;

} catch {
    Err;
}