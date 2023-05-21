
function Err {
    param([string] $Msg = '');
    if ($null -ne $_.Exception) {
        $Msg = $_.Exception.Message;
    }

    if ([string]::IsNullOrEmpty($Msg)) { return; }

    $Msg = [System.Net.WebUtility]::HtmlDecode($Msg);
    Write-Host -ForegroundColor Red $Msg;
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
    Write-Host "    Press any key to exit...";
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp");
}
