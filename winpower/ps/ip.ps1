Set-Location 'c:/winpower';

# Include the library functions
. "lib/func";
. "lib/Paramize";

function findIP([string] $type) {

    $timeout = 3000;
    $stopwatch = $null;
    $job = $null;

    try {
        # Start a background job to fetch the IP
        $job = Start-Job -ScriptBlock {
            param($type);
            try {
                if ($type -eq 'public') {
                    return (Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -ErrorAction Stop | Select-Object -ExpandProperty ip);
                } else {
                    return (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*" | Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -ieq 'Dhcp'}).IPAddress;
                }
            } catch { return $null; }
        } -ArgumentList $type;

        # Start a stopwatch to measure elapsed time
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew();

        # Loop until the timeout seconds or the job is completed
        while ($job.State -eq "Running") {
            if ($stopwatch.ElapsedMilliseconds -eq $timeout) { break; }

            # Update progress bar
            $percentComplete = [Math]::Min($stopwatch.ElapsedMilliseconds / 30, 100)

            pbar $stopwatch.ElapsedMilliseconds $timeout
            # Write-Progress -Activity "Fetching Public IP" -PercentComplete $percentComplete
            Start-Sleep -Milliseconds 100
        }
        hidePbar;

        return Receive-Job $job;
    } catch {
        throw $_.Exception;
    } finally {
        # Stop the stopwatch
        if ($null -ne $stopwatch) { $stopwatch.Stop(); }

        # Clean up the job
        if ($null -ne $job ) { Remove-Job -Id $job.Id -Force; }
    }
}

try {

    $pm = [Paramize]::new();

    $pm.add(@{
        lName = 'type'
        sName = 't'
        def   = 'public'
    });

    $pm.add(@{
        lName = 'copy'
        sName = 'c'
        def   = 'n'
    });

    $pm.validate($args);

    $type = $pm.hitOrDef('type');
    if (-not ($type.ToLower() -in 'public', 'local')) {
        throw 'Arugment for type must be either "public" or "local"';
    }

    $copy = $pm.hitOrDef('copy');
    if (-not ($copy.ToLower() -in 'y', 'n')) {
        throw 'Argument for copy to clipboard must be either "y" or "n"'
    }

    $ip = findIP($type);

    if ($null -eq $ip -or $ip -eq '') {
        throw 'WinPower couldn''t find the IP address as specified';
    }

    Highlight "IP Address: $ip";

    if ($copy -ieq 'y') {
        Set-Clipboard $ip;
        Write-Host 'IP was copied to the clipboard';
    }

} catch {
    Err;
}