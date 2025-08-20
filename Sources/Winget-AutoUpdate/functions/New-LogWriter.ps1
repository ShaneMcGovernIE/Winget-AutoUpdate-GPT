function New-LogWriter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $LogFile
    )

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

    return [System.IO.StreamWriter]::new($LogFile, $true, [System.Text.Encoding]::UTF8)
}
