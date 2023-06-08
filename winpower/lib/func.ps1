
# WinPower Version
$winVer = '5.0.0'

$registryPath = 'HKCU:\Software\WinPower';

function winpower {
    HmWrite "
 __    __ _         ___
/ / /\ \ (_)_ __   / _ \_____      _____ _ __ " Green $false;
    HmWrite "&#x26A1;" Yellow $false;
    HmWrite "
\ \/  \/ / | '_ \ / /_)/ _ \ \ /\ / / _ \ '__|
 \  /\  /| | | | / ___/ (_) \ V  V /  __/ |
  \/  \/ |_|_| |_\/    \___/ \_/\_/ \___|_|"  Green $false;

    Write-Host " v$winVer`n" -ForegroundColor Red;
    Write-Host "Type ""whelp -list"" to learn about available WP commands.";
    Write-Host "Visit https://wp.rootdata21.com for information.`n";
    Exit;
}

function savePref([string] $key, $val, [boolean]$secure=$false) {
    # Create the registry key if it doesn't exist
    if (!(Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    if ($secure) { $val = md5($val); }

    # Set the value in the registry
    Set-ItemProperty -Path $registryPath -Name $key -Value $val
}

function getPref([string] $key, $def = $null, $secure = $false) {

    # Create the registry key if it doesn't exist
    if (!(Test-Path -Path $registryPath)) { return $def; }

    try {
        $val = Get-ItemProperty -Path $registryPath -Name $key -ErrorAction SilentlyContinue
    } catch {
    }

    if ($null -eq $val) { $val = $def; }

    if ($secure) {
        return md5($val.$($key));
    }

    return $val.$($key);
}

function removeWPPref() {
    if (!(Test-Path $registryPath)) { return; }
    Remove-Item -Path $registryPath;
}

function removePref([string]$key) {
    if (!(Test-Path $registryPath)) { return; }

    # Delete a registry value
    Remove-ItemProperty -Path $registryPath -Name $key
}

function md5([string]$str) {
    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider;
    $hashBytes = [System.Text.Encoding]::UTF8.GetBytes($str);
    $md5HashBytes = $md5.ComputeHash($hashBytes);
    return [System.BitConverter]::ToString($md5HashBytes).Replace("-", "");
}

function matchPass([string]$pass) {

    $inPref = getPref 'pass' $null;
    if ($null -ieq $inPref) {
        throw "&#10060; No password was created`nPlease reinstall WinPower";
    }

    $pass = md5 $pass;
    return ($pass -eq $inPref);
}

function showWarn([string] $msg, [string]$before = '',[string] $icon = '&#9940;') {
    $msg = "$before$icon $msg"
    $msg = [System.Net.WebUtility]::HtmlDecode($msg);
    Write-Host $msg -ForegroundColor Yellow;
}

function getPass([string]$msg='Enter winpower password: ') {
    Write-Host $msg -NoNewline;

    $password = ""
    $consoleKeyInfo = $null

    # Read each character until Enter is pressed
    while (($consoleKeyInfo = [System.Console]::ReadKey($true)).Key -ne "Enter") {
        if ($consoleKeyInfo.Key -eq "Backspace") {
            if ($password.Length -gt 0) {
                # Remove the last character from the password
                $password = $password.Substring(0, $password.Length - 1)

                # Move the cursor back by one character
                [System.Console]::SetCursorPosition([System.Console]::CursorLeft - 1, [System.Console]::CursorTop)

                # Replace the character with a space
                Write-Host -NoNewline " "
                [System.Console]::SetCursorPosition([System.Console]::CursorLeft - 1, [System.Console]::CursorTop)
            }
        } else {
            # Add the character to the password
            $password += $consoleKeyInfo.KeyChar

            # Display an asterisk instead of the actual character
            Write-Host -NoNewline "*" -ForegroundColor Cyan
        }
    }

    # add line break
    Write-Host "";
    return $password;
}

function ucFirst([string]$str) {
    return $str.Substring(0, 1).ToUpper() + $str.Substring(1);
}

function coalesce($val, $fuse) {
    if ($null -eq $val) { return $fuse; }
    return $val;
}

function Err {
    param([string] $Msg = '');
    if ($null -ne $_.Exception) {
        $Msg = $_.Exception.Message;
    }

    if ([string]::IsNullOrEmpty($Msg)) { return; }

    $Msg = [System.Net.WebUtility]::HtmlDecode($Msg);
    Write-Host -ForegroundColor Red $Msg;
}

function Warn ([string] $msg) {
    if ([string]::IsNullOrEmpty($Msg)) { return; }

    $Msg = [System.Net.WebUtility]::HtmlDecode($Msg);
    Write-Host -ForegroundColor DarkYellow $Msg;
}

function Highlight {
    param([string] $Msg = '');
    Write-Host -ForegroundColor DarkYellow $Msg;
}

function HmWrite {
    param ([string] $msg, [string]$color=((Get-Host).UI.RawUI.ForegroundColor), [boolean]$break=$true)
    $msg = [System.Net.WebUtility]::HtmlDecode($msg);
    if ($break) {
        Write-Host $msg -ForegroundColor $color;
    } else {
        Write-Host $msg -ForegroundColor $color -NoNewline;
    }
}

function PressToExit {
    Write-Output "    Press any key to exit...";
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
}

function escapeArgs($arg) {
    return $arg | ForEach-Object {
        $quotedArg = $_ -replace '"', '""'  # Escape any existing double quotes
        $quotedArg = "`"$quotedArg`""       # Quote the argument with double quotes
        $quotedArg
    };
}

function IsAdmin {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
}

function RunAsAdmin ($file, $arg) {
    if (-not (IsAdmin)) {
        Start-Process powershell -Verb RunAs "-File c:/winpower/ps/$file.ps1 $(escapeArgs $arg)"
        Exit
    }
}

function pbar {
    param (
        [Parameter(Mandatory=$true)]
        [int] $Completed,
        [Parameter(Mandatory=$true)]
        [int] $Total,
        [string] $guide = '_',
        [string] $runner   = '*',
        [boolean] $showComplete = $true
    )

    $percentComplete = ($Completed / $Total) * 100
    if ($percentComplete -gt 100) { $percentComplete = 100; }

    $progressWidth = [math]::Floor(($percentComplete / 100) * 25)
    $completedBar = $runner * $progressWidth
    $remainingBar = $guide * (25 - $progressWidth)

    $output = "[$completedBar$remainingBar]";

    if ($showComplete) {
        $output += ' ' + $percentComplete.ToString("F2") + '%';
    }

    [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)
    Write-Host -NoNewline $output -ForegroundColor Green;
}

function hidePbar {
    $oriTop = [System.Console]::CursorTop

    # Set the cursor position to the line you want to hide
    [System.Console]::SetCursorPosition(0, $oriTop)

    # Clear the line by overwriting it with spaces
    Write-Host (" " * [System.Console]::WindowWidth) -NoNewline;

    # Restore the cursor position
    [System.Console]::SetCursorPosition(0, $oriTop)
}
