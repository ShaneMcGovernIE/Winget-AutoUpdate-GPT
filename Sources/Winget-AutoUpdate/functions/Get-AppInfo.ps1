#Get the winget App Information

Function Get-AppInfo ($AppID) {
    try {
        $info = & $winget show $AppID --accept-source-agreements --output json | ConvertFrom-Json
    }
    catch {
        return $null
    }

    return $info.ReleaseNotesUrl
}
