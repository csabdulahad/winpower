Set-Location 'c:/winpower';

# Include the library functions
. "lib/func";
. "lib/Paramize";

function OpenPWD {
    $clear = Read-Host "Open PWD instad? (y/n)";
    if ($clear -ieq 'y') { return $env:origin; }
    else { Throw ""; }
}

try {

    $pm = [Paramize]::new();
    $pm.add(@{
        lName = 'path'
        sName = 'p'
        msg   = 'The path to be opened in the explorer.'
        def   = $env:origin
    });

    $pm.cmd('me');
    $pm.cmd('d');
    $pm.cmd('dl');

    $pm.validate($args);

    if ($pm.hitCmd('me')) {
        $path = $env:USERPROFILE;
    } elseif ($pm.hitCmd('d')) {
        $path = [System.Environment]::GetFolderPath('Desktop');
    } elseif ($pm.hitCmd('dl')) {
        $path = [System.Environment]::GetFolderPath('User') + '\Downloads';
    } else {
        if ($pm.hit('path')) {
            $path = $pm.hitOrDef('path');
        } else {
            # Get the path from the clipboard
            $path = Get-Clipboard;
            if ($null -eq $path) {
                $path = $env:origin;
            }
        }
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