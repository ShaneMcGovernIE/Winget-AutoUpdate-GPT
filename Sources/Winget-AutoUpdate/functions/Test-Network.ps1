<#
.SYNOPSIS
    Checks for internet connectivity.
.PARAMETER TimeoutSeconds
    Total number of seconds to wait for connectivity before timing out. Default: 300.
.PARAMETER RetryIntervalSeconds
    Seconds to wait between connection attempts. Default: 10.
#>
function Test-Network {
    [CmdletBinding()]
    param(
        [int]$TimeoutSeconds = 300,
        [int]$RetryIntervalSeconds = 10
    )

    Write-ToLog "Checking internet connection..." "Yellow"

    try {
        $NlaRegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet"
        $ncsiHost = Get-ItemPropertyValue -Path $NlaRegKey -Name ActiveWebProbeHost
    }
    catch {
        $ncsiHost = "www.msftconnecttest.com"
    }

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $notifSent = $false

    while ($stopWatch.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
        if (Test-Connection -TargetName $ncsiHost -Quiet -Count 1 -ErrorAction SilentlyContinue) {
            Write-ToLog "Connected !" "Green"

            # Check for metered connection
            try {
                [void][Windows.Networking.Connectivity.NetworkInformation, Windows, ContentType = WindowsRuntime]
                $cost = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile().GetConnectionCost()

                $networkCostTypeName = [Windows.Networking.Connectivity.NetworkCostType]::GetName(
                    [Windows.Networking.Connectivity.NetworkCostType],
                    $cost.NetworkCostType
                )
            }
            catch {
                Write-ToLog "Could not evaluate metered connection status - skipping check." "Gray"
                return $true
            }

            if ($cost.ApproachingDataLimit -or $cost.OverDataLimit -or $cost.Roaming -or $cost.BackgroundDataUsageRestricted -or ($networkCostTypeName -ne "Unrestricted")) {
                Write-ToLog "Metered connection detected." "Yellow"

                if ($WAUConfig.WAU_DoNotRunOnMetered -eq 1) {
                    Write-ToLog "WAU is configured to bypass update checking on metered connection"
                    return $false
                }
                else {
                    Write-ToLog "WAU is configured to force update checking on metered connection"
                    return $true
                }
            }
            else {
                return $true
            }
        }
        else {
            if (-not $notifSent -and $stopWatch.Elapsed.TotalSeconds -ge 300) {
                Write-ToLog "Notify 'No connection' sent." "Yellow"

                $Title = $NotifLocale.local.outputs.output[0].title
                $Message = $NotifLocale.local.outputs.output[0].message
                $MessageType = "warning"
                $Balise = "Connection"
                Start-NotifTask -Title $Title -Message $Message -MessageType $MessageType -Balise $Balise
                $notifSent = $true
            }

            Start-Sleep -Seconds $RetryIntervalSeconds
        }
    }

    Write-ToLog "Timeout. No internet connection !" "Red"

    $Title = $NotifLocale.local.outputs.output[1].title
    $Message = $NotifLocale.local.outputs.output[1].message
    $MessageType = "error"
    $Balise = "Connection"
    Start-NotifTask -Title $Title -Message $Message -MessageType $MessageType -Balise $Balise

    return $false
}
