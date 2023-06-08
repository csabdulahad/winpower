Set-Location 'c:/winpower';

# Include the library functions
. "lib/func";
. "lib/Paramize";

try {

    RunAsAdmin 'piyon' $args;

    $pm = [Paramize]::new();
    $pm.add(@{
        lName = 'Path'
        sName = 'P'
        msg   = 'It must be the path you want to add to the Environment Variable (EV).'
        def   = $env:origin
    });
    $pm.cmd('r');
    $pm.validate($args);

    $oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine");

    if ($pm.hitCmd('r')) {
        if ($null -eq $args[1] -or $args[1] -eq '') {
            Throw '    The path to be removed from Environment Variable can''t be empty';
        }

        $path = $args[1];
        $oldPath = $oldPath -split ';';
        $toBePath = $oldPath | Where-Object { $_ -ne $path }
        $path = $toBePath -join ';';

    } else {
        $path = $pm.hitOrDef('path');
        $path = "$oldPath;$path";
    }

    # Append the new path to the existing one & then add to the env. variables
    [Environment]::SetEnvironmentVariable("Path", $path, "Machine");

} catch {
    Err;
    PressToExit;
}