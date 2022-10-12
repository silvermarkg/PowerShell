Write-Host "MyInvocation.MyCommand.Name = $($MyInvocation.MyCommand.Name)"
Write-Host "MyInvocation.ScriptName = $($MyInvocation.ScriptName)"
Write-Host "MyInvocation.MyCommand.Source = $($MyInvocation.MyCommand.Source)"
Write-Host "Script Basename = $((Get-ChildItem -Path $MyInvocation.MyCommand.Source).BaseName)"
Write-Host "Log file = $($MyInvocation.MyCommand.Name -replace '.ps1', '.log')"
Write-Host "PSCommandPath $($PSCommandPath)"
