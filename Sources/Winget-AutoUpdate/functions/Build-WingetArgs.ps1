Function Build-WingetArgs {
    param(
        [Parameter(Mandatory = $true)][string]$CommandType,
        [Parameter(Mandatory = $true)][string]$AppId,
        [string]$Override,
        [string]$Custom,
        [string[]]$AdditionalParams = @()
    )

    switch ($CommandType.ToLower()) {
        'upgrade' {
            $base = @('upgrade', '--id', $AppId, '-e', '--accept-package-agreements', '--accept-source-agreements', '-s', 'winget')
        }
        'install' {
            $base = @('install', '--id', $AppId, '-e', '--accept-package-agreements', '--accept-source-agreements', '-s', 'winget')
        }
        'uninstall' {
            $base = @('uninstall', '--id', $AppId, '-e', '--accept-source-agreements')
        }
        default {
            throw "Unsupported command type: $CommandType"
        }
    }

    $cmdBase = $base + $AdditionalParams
    $baseLog = "Winget $($cmdBase -join ' ')"

    if ($Override) {
        $args = $cmdBase + @('--override', $Override)
        $log = "Running (overriding default): $baseLog --override $Override"
    }
    elseif ($Custom) {
        $customParts = $Custom -split ' '
        $args = $cmdBase + @('-h') + $customParts
        $log = "Running (customizing default): $baseLog -h $Custom"
    }
    else {
        $args = $cmdBase + @('-h')
        $log = "Running: $baseLog -h"
    }

    return @($args, $log)
}
