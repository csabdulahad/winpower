
# WinPower Version
$winVer = '3.0.0'

function winpower {
    Write-Host -ForegroundColor Green "
 __    __ _         ___
/ / /\ \ (_)_ __   / _ \_____      _____ _ __
\ \/  \/ / | '_ \ / /_)/ _ \ \ /\ / / _ \ '__|
 \  /\  /| | | | / ___/ (_) \ V  V /  __/ |
  \/  \/ |_|_| |_\/    \___/ \_/\_/ \___|_|"  -NoNewline;

    Write-Host " v$winVer`n" -ForegroundColor Red;
    Write-Host "Visit https://wp.rootdata21.com for information.`n";
    Exit;
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
    param ([string] $Msg)
    $msg = [System.Net.WebUtility]::HtmlDecode($msg);
    Write-Host $msg;
}

function PressToExit {
    Write-Output "    Press any key to exit...";
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp");
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
