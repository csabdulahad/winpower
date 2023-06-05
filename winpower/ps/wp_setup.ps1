function SetExePoli([string] $p = 'RemoteSigned') {
    Set-ExecutionPolicy $p CurrentUser;
}

# Get the last execution policy
$lastExePolicy = $args[1];

try {
    Write-Host "
                 __    __ _         ___
                / / /\ \ (_)_ __   / _ \_____      _____ _ __
                \ \/  \/ / | '_ \ / /_)/ _ \ \ /\ / / _ \ '__|
                 \  /\  /| | | | / ___/ (_) \ V  V /  __/ |
                  \/  \/ |_|_| |_\/    \___/ \_/\_/ \___|_|
    ----------------------------------------------------------------------
    |                       WinPower Installation                        |
    ----------------------------------------------------------------------
    ";

    # Validate whether the WinPower folder installation is at right location
    if (-Not(Test-Path -Path "c:/winpower")) { Throw 'Make sure the winpower folder is located at: "c:/winpower"'; }

    # set winpower folder location
    Set-Location -Path "c:/winpower";

    # Execute the helper functions
    . "lib/func";

    Write-Host "
    Welcome to WinPower $winVer!

    Warning: You are about to grant WinPower permissions to run and execute
    the following:

    1. Create a self-signing certificate
    2. Sign all the winpower ps scripts
    3. Restore the execution policy security
    4. Add WinPower to System-Level environment variable

    Disclaimer: In no event will we be liable for any loss or damage,
    including without limitation, indirect or consequential loss or damage,
    or any loss or damage whatsoever arising from the use of this notice.
    ";


    # Check if we have last execution policy
    if ($args.Length -lt 1) {
        Throw "`n    &#10060; No direct access allowed to WinPower setup.";
    }

    # Check for installation agreement via exe installer
    $consent = $args[0];
    if ($consent -ine 'y') {
        # Get the consent
        $consent = Read-Host("    Do you agree? (y/n)");
        if ($consent.ToLower() -ne 'y') {
            Throw "`n    &#10060; Installation agreement was declined.`n    WinPower will not be installed.`n";
        }
    } else {
        Write-Host "    Do you agree? (y/n): y";
    }


    # Create a certificate
    HmWrite "`n    Creating self-signing certificate..."
    $params = @{
        Subject = 'CN=WinPower Code Signing Cert'
        Type = 'CodeSigning'
        CertStoreLocation = 'Cert:\CurrentUser\My'
        HashAlgorithm = 'sha256'
    }
    $cert = New-SelfSignedCertificate @params;
    HmWrite "    &#9989; Certificate created.";


    # Assign the certificate to the winpower scripts
    HmWrite "`n    Singing winpower scripts...";
    $files = Get-ChildItem -Path "ps" -File;
    foreach ($file in $files) {
        if ($file.Name -eq 'wp_setup.ps1') { continue; }
        [void](Set-AuthenticodeSignature "ps/$file" $cert);
        HmWrite "    &#9989; $file";
    }


    # Restore the execution policy to RemoteSigned
    HmWrite "`n    Restoring the execution policy....";
    SetExePoli;
    HmWrite "    &#9989; Execution policy restored";


    # Add WinPower to the system-level environment variable
    HmWrite "`n    Adding WinPower to System-Level environment variable....";
    & "ps/piyon.ps1" "c:/winpower/cmd";
    HmWrite "    &#9989; WinPower added to env. variable";


    # Congratulate the user
    HmWrite "`n`n    &#9889;Congratulation!`n    WinPower setup has been completed successfully.`n"

} catch {
    # Set back the last one as we must!
    SetExePoli $lastExePolicy;

    if (Test-Path function:\Err) {
        Err;
    } else {
        Write-Host -BackgroundColor Black -ForegroundColor Yellow $_.Exception.Message;
    }
} finally {
    if (Test-Path function:\PressToExit) {
        PressToExit;
    } else {
        Write-Host "Exiting in 5 seconds...";
        Start-Sleep -Second 5;
    }
}
