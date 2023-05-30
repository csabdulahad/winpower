Set-Location 'c:/winpower';

# Include the library functions
. "lib/func";
. "lib/Paramize";

try {

    $pm = [Paramize]::new();
    $pm.add(@{
        lName = 'Path'
        sName = 'P'
        msg   = 'It must be the path you want to add to the Environment Variable (EV).'
        def   = $env:origin
    });
    $pm.validate($args);

    $path = $pm.hitOrDef('path');
    RunAsAdmin 'piyon' $path;

    # Append the new path to the existing one & then add to the env. variables
    $oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine");
    $newPathList = "$oldPath;$path";
    [Environment]::SetEnvironmentVariable("Path", $newPathList, "Machine");

} catch {
    Err;
}