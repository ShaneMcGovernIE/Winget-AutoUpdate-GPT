. "$PSScriptRoot/../Sources/Winget-AutoUpdate/functions/Build-WingetArgs.ps1"

Describe 'Build-WingetArgs' {
    It 'returns default arguments' {
        $args, $log = Build-WingetArgs -CommandType install -AppId 'Test.App'
        ($args -join ' ') | Should -Be 'install --id Test.App -e --accept-package-agreements --accept-source-agreements -s winget -h'
        $log | Should -Be 'Running: Winget install --id Test.App -e --accept-package-agreements --accept-source-agreements -s winget -h'
    }

    It 'returns override arguments' {
        $args, $log = Build-WingetArgs -CommandType install -AppId 'Test.App' -Override '/S'
        ($args -join ' ') | Should -Be 'install --id Test.App -e --accept-package-agreements --accept-source-agreements -s winget --override /S'
        $log | Should -Be 'Running (overriding default): Winget install --id Test.App -e --accept-package-agreements --accept-source-agreements -s winget --override /S'
    }

    It 'returns custom arguments' {
        $args, $log = Build-WingetArgs -CommandType install -AppId 'Test.App' -Custom '--custom foo'
        ($args -join ' ') | Should -Be 'install --id Test.App -e --accept-package-agreements --accept-source-agreements -s winget -h --custom foo'
        $log | Should -Be 'Running (customizing default): Winget install --id Test.App -e --accept-package-agreements --accept-source-agreements -s winget -h --custom foo'
    }
}
