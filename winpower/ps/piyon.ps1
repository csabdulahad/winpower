Set-Location 'c:/winpower';

# Include the library functions
. "lib/func";
. "lib/Paramize";

function fixPath($path) {
    $fixedPath = $path.Replace('/', '\');
    return $fixedPath
}

function exists([string] $path, [string] $evPaths) {
    $pathArr = $evPaths -split ';';
    return  $pathArr -contains $path;
}

try {

    $pm = [Paramize]::new();

    $pm.add(@{
        lName = 'Path'
        sName = 'P'
        msg   = 'It must be the path you want to add to the Environment Variable (EV).'
        def   = $env:origin
    });

    $pm.cmd('q');
    $pm.cmd('fix');
    $pm.cmd('list');
    $pm.cmd('r');

    $pm.validate($args);

    $oldPath = fixPath([Environment]::GetEnvironmentVariable("Path", "Machine"));

    # Check if the requested path already exists if it is add command
    if ($pm.hit('path')) {
        $path = $pm.hitVal('path');
        $path = fixPath($path);
        if (exists $path $oldPath) {
            Highlight "Path already exists in EV: $path";
            exit;
        }
    }

    if ($pm.hitCmd('q')) {
        if ($null -eq $args[1] -or $args[1] -eq '') {
            Throw '    The path to be checked in Environment Variable can''t be empty';
        }

        $path = fixPath($args[1]);
        if (exists $path $oldPath) {
            Success("Path exists: $path");
        } else {
            Highlight("Path doesn't exist: $path");
        }

        exit;
    }

    if ($pm.hitCmd('list')) {
        $pathArr = $oldPath -split ';';
        Write-Host "$($pathArr.Count) paths in EV:";
        foreach ($path in $pathArr) {
            Write-Host "    $path"
        }

        exit;
    }

    RunAsAdmin 'piyon' $args;

    if ($pm.hitCmd('r')) {
        if ($null -eq $args[1] -or $args[1] -eq '') {
            Throw '    The path to be removed from Environment Variable can''t be empty';
        }

        $path = $args[1];
        $oldPath = $oldPath -split ';';
        $toBePath = $oldPath | Where-Object { $_ -ne $path }
        $path = $toBePath -join ';';
    } elseif ($pm.hitCmd('fix')) {
        $path = $oldPath;
    } else {
        $path = fixPath($pm.hitOrDef('path'));
        $path = "$oldPath;$path";
    }

    # Append the new path to the existing one & then add to the env. variables
    [Environment]::SetEnvironmentVariable("Path", $path, "Machine");

} catch {
    Err;
    PressToExit;
}