
# get cmd loaction and set the winpower default location
$env:origin = Get-Location;
Set-Location 'c:/winpower';

# make sure winpower is properly installed and then import files
if (-Not (Test-Path -Path 'lib/func.ps1')) {
    Write-Host "WinPower installation is invalid`nPlease reinstall." -ForegroundColor Red;
    Exit;
}

. 'lib/func';
. 'lib/Paramize';

try {

    $pm = [Paramize]::new();
    $pm.disablePosCheck();
    $pm.cmd(@{ cmd = 'v' });
    $pm.cmd(@{ cmd = 'i' });
    $pm.validate($args);

    # version command
    if ($args.Length -eq 0 -or $pm.hitCmd('v')) { winpower; }

    # install/reinstall command
    if ($pm.hitCmd('i')) {
        $con = coalesce $args[1] 'n';
        & cmd /c "wp_setup $con";
        Exit;
    }

    # make sure we have got known command to do
    $fileName = $args[0];
    if (-Not(Test-Path "ps/$fileName.ps1")) {
        Throw "Unknown command`nType ""whelp -list"" for more help";
    }

    # now load that file with the argument passed-in
    $wpArg = ($args | Select-Object -Skip 1);
    if ($null -eq $wpArg) { $wpArg = @(); }

    Invoke-Expression "& `"ps/$fileName.ps1`" $(escapeArgs $wpArg)"

} catch {
    Err;
}
