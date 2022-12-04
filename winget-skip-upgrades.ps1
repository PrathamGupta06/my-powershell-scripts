# Write the software ids to skip in winget-skip-upgrades.txt file
class Software {
    [string]$Name
    [string]$Id
    [string]$Version
    [string]$AvailableVersion
}

$upgradeResult = winget upgrade | Out-String 

$lines = $upgradeResult.Split([Environment]::NewLine)


# Find the line that starts with Name, it contains the header
$fl = 0
while (-not $lines[$fl].StartsWith("Name"))
{
    $fl++
}

# Line $i has the header, we can find char where we find ID and Version
$idStart = $lines[$fl].IndexOf("Id")
$versionStart = $lines[$fl].IndexOf("Version")
$availableStart = $lines[$fl].IndexOf("Available")
$sourceStart = $lines[$fl].IndexOf("Source")

# Now cycle in real package and split accordingly
$upgradeList = @()
For ($i = $fl + 1; $i -le $lines.Length; $i++) 
{
    $line = $lines[$i]
    if ($line.Length -gt ($availableStart + 1) -and -not $line.StartsWith('-'))
    {
        $name = $line.Substring(0, $idStart).TrimEnd()
        $id = $line.Substring($idStart, $versionStart - $idStart).TrimEnd()
        $version = $line.Substring($versionStart, $availableStart - $versionStart).TrimEnd()
        $available = $line.Substring($availableStart, $sourceStart - $availableStart).TrimEnd()
        $software = [Software]::new()
        $software.Name = $name;
        $software.Id = $id;
        $software.Version = $version
        $software.AvailableVersion = $available;
        $software.Id = $Software.Id -replace '[^a-zA-Z0-9.]', '' # Remove special chars
        $upgradeList += $software
    }
}

# Show all the software that can be upgraded
# $upgradeList | Format-Table

$toSkip = Get-Content -Path "winget-skip-upgrades.txt" -Encoding UTF8

# Print the list of packages present in the upgradelist and toskip
Write-Host "These Packages can be upgraded but will be skipped"
$upgradeList | Where-Object { $toSkip.Contains($_.Id) } | Format-Table

# Print the list of packages present in the upgradelist and not toskip
$toUpgrade = $upgradeList | Where-Object { -not $toSkip.Contains($_.Id) }
Write-Host "These Packages will be upgraded"
$toUpgrade | Format-Table

foreach ($package in $toUpgrade) 
{
    Write-Host "====== Upgrading $($package.id) ======"
    Write-Host "Current version: $($package.Version)"
    Write-Host "Available version: $($package.AvailableVersion)"
    & winget upgrade $package.id
    $endline = "-" * 40
    Write-Host $endline
    Write-Host ""
}
