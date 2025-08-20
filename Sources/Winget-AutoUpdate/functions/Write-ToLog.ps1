#Write to Log Function

function Write-ToLog {

    [CmdletBinding()]
    param(
        [Parameter()] [String] $LogMsg,
        [Parameter()] [String] $LogColor = "White",
        [Parameter()] [Switch] $IsHeader = $false,
        [Parameter()] [System.IO.StreamWriter] $LogWriter
    )

    if (-not $LogWriter -and $global:LogWriter) {
        $LogWriter = $global:LogWriter
    }

    if (-not $LogWriter) {
        if (!(Test-Path $LogFile)) {
            New-Item -ItemType File -Path $LogFile -Force | Out-Null

            $NewAcl = Get-Acl -Path $LogFile
            $identity = New-Object System.Security.Principal.SecurityIdentifier S-1-5-11
            $fileSystemRights = "Modify"
            $type = "Allow"
            $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
            $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
            $NewAcl.SetAccessRule($fileSystemAccessRule)
            Set-Acl -Path $LogFile -AclObject $NewAcl
        }
    }

    if ($IsHeader) {
        $Log = "#" * 65 + "`n#    $(Get-Date -Format (Get-culture).DateTimeFormat.ShortDatePattern) - $LogMsg`n" + "#" * 65
    }
    else {
        $Log = "$(Get-Date -UFormat \"%T\") - $LogMsg"
    }

    $Log | Write-host -ForegroundColor $LogColor

    if ($LogWriter) {
        $LogWriter.WriteLine($Log)
    }
    else {
        $Log | Out-File -FilePath $LogFile -Append
    }

}
