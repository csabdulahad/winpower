
Set-Location "c:/winpower_dev";

$setupFile = "winpower/ps/setup.ps1";
$ver = $args[0];

# Read the content of the script file
$setupCode = Get-Content -Path $setupFile

# Find and replace the variable assignment line in the script content
$setupCode = $setupCode -replace '\$winVer = .+', "`$winVer = '$ver'"

# Write the updated content back to the script file
$setupCode | Set-Content -Path $setupFile