#Function to get the outdated app list, in formatted array

function Get-WingetOutdatedApps {

    Param(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "You MUST supply value for winget repo, we need it")]
        [ValidateNotNullorEmpty()]
        [string]$src
    )
    class Software {
        [string]$Name
        [string]$Id
        [string]$Version
        [string]$AvailableVersion
    }

    #Get list of available upgrades in JSON format
    try {
        $upgradeResult = & $Winget upgrade --source $src --output json | ConvertFrom-Json
    }
    catch {
        Write-ToLog "Error while recieving winget upgrade list: $_" "Red"
        $upgradeResult = $null
    }

    if (-not $upgradeResult) {
        return "No update found. 'Winget upgrade' output:`n$upgradeResult"
    }

    # Extract package list from JSON
    $packages = $upgradeResult |
        Select-Object -ExpandProperty Sources -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Packages -ErrorAction SilentlyContinue

    if (-not $packages) {
        return "No update found. 'Winget upgrade' output:`n$upgradeResult"
    }

    # Map packages to Software objects
    $upgradeList = foreach ($pkg in $packages) {
        [Software]@{
            Name            = $pkg.PackageName
            Id              = $pkg.PackageIdentifier
            Version         = $pkg.InstalledVersion
            AvailableVersion = $pkg.AvailableVersion
        }
    }

    #If current user is not system, remove system apps from list
    if ($IsSystem -eq $false) {
        $SystemApps = Get-Content -Path "$WorkingDir\config\winget_system_apps.txt" -ErrorAction SilentlyContinue
        $upgradeList = $upgradeList | Where-Object { $SystemApps -notcontains $_.Id }
    }

    return $upgradeList | Sort-Object { Get-Random }

}
