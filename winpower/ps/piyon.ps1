# Include the library functions
. "c:/winpower/lib/func.ps1";

try {

    $path = $args[0];
    if ($null -eq $path) {
        $path = Get-Location;
    }


    # Append the new path to the existing one & then add to the env. variables
    $oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine");
    $newPathList = "$oldPath;$path";
    [Environment]::SetEnvironmentVariable("Path", $newPathList, "Machine");

} catch {
    Err;
    PressToExit;
}