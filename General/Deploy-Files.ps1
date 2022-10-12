
<#PSScriptInfo
.DESCRIPTION
 Copies or removes files to/from a destination

.VERSION 1.0.0
.GUID 
.AUTHOR Mark Goodman (@silvermarkg)
.COMPANYNAME 
.COPYRIGHT 2022 Mark Goodman
.TAGS 
.LICENSEURI https://gist.github.com/silvermarkg/f58688cacdd51f9228441b8d124a6a03
.PROJECTURI 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Version 1.0.0 | 12-Oct-2022 | Initial script

#>

<#
  .SYNOPSIS
  Copies or removes files to/from a destination.

  .DESCRIPTION
  Used to deploy files and folders to destination folder. Use the Path parameter to specify the detination path and the
  Mode parameter to specify whether to Install (copy) or Uninstall (remove) the files.

  Install mode: Files and folders are copied from this scripts root folder ($PSScriptRoot) to the destination path specified 
                by the Path parameter. This script file is not copied.

  Uninstall mode: Files and folders that exist in this scripts root folder ($PSScriptRoot) are removed from the destination 
                  path specified by the Path parameter.

  .PARAMETER Path
  Specifies the destination folder to copy the files to. Folder will be created if it does not exist.
	
  .PARAMETER Mode
  Optional. Defaults to Install
  Specifies whether to Install (copy) or Uninstall (remove) the files.

  .EXAMPLE
  Deploy-Files.ps1 -Path C:\ProgramData\MyApp -Mode Install

  Description
  -----------
  Copies files and folders in the script folder ($PSScriptRoot) to the C:\ProgramData\MyApp folder.

  .EXAMPLE
  Deploy-Files.ps1 -Path C:\ProgramData\MyApp -Mode Uninstall

  Description
  -----------
  Removes files and folders that exist in the script folder ($PSScriptRoot) from the C:\ProgramData\MyApp folder.
#> 

#region - Parameters
[Cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
  [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the destination folder to deploy files to")]
  [ValidateNotNullOrEmpty()]
  [String]$Path,

  [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Specify deployment mode; Install or Uninstall")]
  [ValidateNotNullOrEmpty()]
  [ValidateSet("Install", "Uninstall")]
  [String]$Mode = "Install"
)
#endregion - Parameters

#region - Script Environment
#Requires -Version 5
# #Requires -RunAsAdministrator
Set-StrictMode -Version Latest
#endregion - Script Environment

#region - Functions
#endregion - Functions

#region - Variables
$ScriptName = $MyInvocation.MyCommand.Name
#endregion - Variables

#region - Script
# Determine deployment mode
if ($Mode -eq "Install") {
  # Create target folder if it does not exist
  if (-Not (Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
  }

  # Copy files 
  Copy-Item -Path "$($PSScriptRoot)\*" -Destination $Path -Exclude $ScriptName -Recurse -Force -ErrorAction Stop
}
elseif ($Mode -eq "Uninstall") {
  # Get list of content to remove
  $Items = Get-ChildItem -Path $PSScriptRoot -Exclude $ScriptName
  foreach ($Item in $Items) {
    # Check if item exists
    $RemovePath = Join-Path -Path $Path -ChildPath $Item.Name
    if (Test-Path -Path $RemovePath) {
      # Check if folder
      if ($Item.PSIsContainer) {
        # Remove folder
        Remove-Item -Path $RemovePath -Recurse -Force -ErrorAction Stop
      }
      else {
        # Remove file
        Remove-Item -Path $RemovePath -Force -ErrorAction Stop
      }
    }
  }
}
#endregion - Script