Set-Location 'c:/winpower';

. 'lib/func';
. 'lib/Paramize';

function queryPass([string]$profile) {
    $profileName = $profile;
    $password = ((netsh wlan show profile name="$profileName" key=clear) -match "Key Content\s+:\s+(.*)" -replace "Key Content\s+:\s+", "") -replace "\s", ""
    return $password;
}

try {

    $pm = [Paramize]::new();
    $pm.cmd(@{ cmd = 'list' });
    $pm.add(@{
       lName = 'profile'
       sName = 'p'
       def = '*';
    });

    $pm.add(@{
        lName = 'key'
        sname = 'k'
        def = 'n'
    });

    $pm.add(@{
        lName = 'copy'
        sName = 'c'
        def = 'n'
    });

    $pm.validate($args);

    # validate user credential
    while ($true) {
        $pass = GetPass;
        if ($pass -eq '' -or $pass.Length -lt 4) {
            showWarn "Password must be 4 characters long`n";
            continue;
        }
        break;
    }

    if (!(matchPass $pass)) {
        throw "&#10060; Incorrect password";
    }

    $profiles = (netsh wlan show profile) -match "All User Profile\s+:\s+(.*)" -replace "All User Profile\s+:\s+", "" -replace "^\s+", "";

    if ($pm.hitCmd('list')) {
        $profiles
        exit;
    }

    # count space margin
    $space = 0;
    foreach ($x in $profiles) {
        $spaceLen = $x.Length;
        if ($spaceLen -gt $space) {
            $space = $spaceLen + 4;
        }
    }

    $proArg = $pm.hitOrDef('profile');
    $showOpt = $pm.hitOrDef('key');
    $copyOpt = $pm.hitOrDef('copy');

    if ($proArg -eq '*') {
        if ($showOpt -eq 'n') {
            $profiles;
            exit;
        }

        foreach($pro in $profiles) {
            $toSpace = ' ' * ($space - $pro.Length);
            HmWrite "$pro    $toSpace`:    $(queryPass $pro)";
        }
    } else {
        $pass = queryPass $proArg;
        if ($pass -eq $false) {
            throw "No password found for $proArg";
        }

        $toSpace = ' ' * ($space - $proArg.Length);
        if ($showOpt -eq 'n') {
            HmWrite "$proArg    $toSpace`:    **********";
        } else {
            HmWrite "$proArg    $toSpace`:    $pass";
        }

        if ($copyOpt -eq 'y') {
            Set-Clipboard $pass;
            Highlight "Password has been copied to Clipboard";
        }
    }

} catch {
    Err;
}