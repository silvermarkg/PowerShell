<#PSScriptInfo
.VERSION 1.0
.GUID 
.AUTHOR Mark Goodman (@silvermarkg)
.COMPANYNAME 
.COPYRIGHT 2023 Mark Goodman
.TAGS 
.LICENSEURI https://gist.github.com/silvermarkg/f58688cacdd51f9228441b8d124a6a03
.PROJECTURI 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Version 1.0 | 25-Aug-2023 | Initial script

TODO: Handle special folders and namespaces better
#>

<#
  .SYNOPSIS
  Configures File Explorer Quick Access items

  .DESCRIPTION
  Pins a set of paths to the Quick Access area of File Explorer. You can clear all existing links by using the ClearAll parameter.
  You can specify one or more paths to pin to Quick Access. To specify more than one path, specify and array of values.
  You can specify special folders (eg. Personal, MyPictures) by specifing the specical folder name. To get a list of special folder names run [enum]::GetNames([System.Environment+SpecialFolder])
  You can specify shell: commands (eg. shell:Downloads). Look in the following registry key for shell commands HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\FolderDescriptions

  .PARAMETER Path
  Specifies the path to pin to Quick Access. Specifiy an array to pin multiple paths.
  You can specify special folder names (eg. Personal, MyPictures) to pin special folders.

  .PARAMETER ClearAll
  Optional. Indicates that all existing Quick Access links should be removed before pinning new paths

  .PARAMETER AddThisPC
  Adds This PC special namespace to Quick Access links

  .EXAMPLE
  Set-QuickAccess.ps1 -Path C:\Data

  Description
  -----------
  Adds C:\Data folder as a link in Quick Access.

  .EXAMPLE
  Set-QuickAccess.ps1 -Path Personal,C:\Data -ClearAll

  Description
  -----------
  Clears all exising Quick Access links and then adds the user Documents folder and C:\Data folder as links in Quick Access.
#> 

#region - Parameters
[Cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
  [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the list of paths to pin to Quick Access")]
  [ValidateNotNullOrEmpty()]
  [String[]]$Path,

  [Parameter(Mandatory = $false)]
  [Switch]$ClearAll,

  [Parameter(Mandatory = $false)]
  [Switch]$AddThisPC
)
#endregion - Parameters

#region - Script Environment
Set-StrictMode -Version Latest
#endregion - Script Environment

#region - Functions
function Set-QuickAccess {
  ###################
  # Set-QuickAccess #
  ###################
  #Version: 2017-08-10.01
  #Author: johan.carlsson@innovatum.se

  #Version: 2023-08-25.01
  #Author: Mark Goodman (@silvermarkg)
  # Notes: Updated original function to all namespaces to be passed.

  <#

.SYNOPSIS
Pin or Unpin folders to/from Quick Access in File Explorer.

.DESCRIPTION
Pin or Unpin folders to/from Quick Access in File Explorer.

.EXAMPLE
.\Set-QuickAccess.ps1 -Action Pin -Path "\\server\share\redirected_folders\$env:USERNAME\Links"
Pin the specified UNC server share to Quick Access in File Explorer.

.EXAMPLE
.\Set-QuickAccess.ps1 -Action Unpin -Path "\\server\share\redirected_folders\$env:USERNAME\Links"
Unpin the specified UNC server share from Quick Access in File Explorer.

.NOTES
Thanks to the below sources for inspiration :)
https://blogs.technet.microsoft.com/heyscriptingguy/2013/04/26/use-powershell-to-work-with-windows-explorer/
https://www.reddit.com/r/sysadmin/comments/6g5hz4/removing_pinned_quick_access_pins_via_powershell/

.LINK
https://gallery.technet.microsoft.com/Set-QuickAccess-117e9a89

#>

  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Pin or Unpin folder to/from Quick Access in File Explorer.")]
    [ValidateSet("Pin", "Unpin")]
    [string]$Action,
    [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Path to the folder to Pin or Unpin to/from Quick Access in File Explorer.")]
    [string]$Path,
    [Parameter(Mandatory = $false)]
    [Switch]$Namespace
  )

  Write-Host "$Action to/from Quick Access: $Path.. " -NoNewline

  #Check if specified path is valid (if not namespace)
  if (-Not $Namespace) {
    If ((Test-Path -Path $Path) -ne $true) {
      Write-Warning "Path does not exist."
      return
    }
    #Check if specified path is a folder
    If ((Test-Path -Path $Path -PathType Container) -ne $true) {
      Write-Warning "Path is not a folder."
      return
    }
  }

  #Pin or Unpin
  $QuickAccess = New-Object -ComObject shell.application
  $TargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where { $_.Path -eq "$Path" }
  If ($Action -eq "Pin") {
    If ($TargetObject -ne $null) {
      Write-Warning "Path is already pinned to Quick Access."
      return
    }
    Else {
      $QuickAccess.Namespace($Path).Self.InvokeVerb("pintohome")
    }
  }
  ElseIf ($Action -eq "Unpin") {
    If ($TargetObject -eq $null) {
      Write-Warning "Path is not pinned to Quick Access."
      return
    }
    Else {
      $TargetObject.InvokeVerb("unpinfromhome")
    }
  }

  Write-Host "Done"
}

function Clear-QuickAccess {
  <#
    Version: 1.0 | 25-Aug-2023
    Author: Mark Goodman (@silvermarkg)
  #>

  <#
    .SYNOPSIS
    Clears all items from Quick Access list

    .DESCRIPTION
    Clears all items from Quick Access list
  #>

  [CmdletBinding()]
  Param()

  # Get all items
  $Shell = New-Object -ComObject Shell.Application
  ForEach ($item in $Shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items()) {
    # Unpin item
    Set-QuickAccess -Action Unpin -Path $item.Path
  }
}

function Add-ThisPC {
  <#
    Version: 1.0 | 25-Aug-2023
    Author: Mark Goodman (@silvermarkg)
  #>

  <#
    .SYNOPSIS
    Adds This PC namespace as Quick Access link

    .DESCRIPTION
    Adds This PC namespace as Quick Access link
  #>

  [CmdletBinding()]
  Param()

  # Get all items
  $Shell = New-Object -ComObject Shell.Application
  $Shell.Namespace(0x11).self.InvokeVerb("pintohome")
}

#endregion - Functions

#region - Variables
$ScriptName = $MyInvocation.MyCommand.Name
#endregion - Variables

#region - Script

# Clear all existing Quick Access links if specified
if ($ClearAll) {
  Clear-QuickAccess
}

# Get special folder details
$specialFolder = [enum]::GetNames([System.Environment+SpecialFolder]) | Select-Object -Property @{Name = 'Name'; Expression = { $_ } }, @{Name = 'Path'; Expression = { [Environment]::GetFolderPath($_) } } | Where-Object -Property Path -NE -Value ""

# Add each path specified
ForEach ($item in $Path) {
  # Define splat params
  $params = @{}

  # Check if special folder reference
  if ($specialFolder.Name -contains $item) {
    # Set specail folder path
    $itemPath = $specialFolder | Where-Object -Property Name -EQ -Value $item | Select-Object -ExpandProperty Path
  }
  else {
    # Set path
    $itemPath = $item
  }

  # Add namespace param if needed
  if ($itemPath.toLower().StartsWith("shell:")) {
    $params.Add("Namespace",$true)
  }

  # Pin path
  Set-QuickAccess -Action Pin -Path $itemPath @params
}

# Add This PC if specfied
if ($AddThisPC) {
  Add-ThisPC
}

#endregion - Script