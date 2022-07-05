<#
  .NOTES
  Author: Mark Goodman
  Version 1.0.1
  Date: 05-Jul-2022

  Release Notes
  -------------
  Insipration and code from https://jdhitsolutions.com/blog/powershell/7931/extracting-icons-with-powershell/

  Update History
  --------------
  1.0.1 | 05-Jul-2022 | Updated help info
  1.0.0 | 23-Mar-2022 | Initial script

  License
  -------
  MIT LICENSE
  
  Copyright (c) 2022 Mark Goodman (silvermarkg)

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
  files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
  Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the 
  Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  .SYNOPSIS
  Extracts icon from executable and saves as PNG file

  .PARAMETER Path
  The path to the executable to extract the icon resource from
	
  .PARAMETER Destination
  The path to save the .png file to. Only specify the destination folder. Defaults to current location.
	
  .EXAMPLE
  Set-Location -Path C:\
  Extract-Icon.ps1 -Path C:\MyApp.exe
	
	Description
	-----------
	Extracts the icon from C:\MyApp.exe and saves as C:\MyApp.png
#>

#region - Parameters
[Cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param(
  # Mandatory parameter
  [Parameter(Mandatory=$true,HelpMessage="Specify the path to the file containing the icon",Position=0)]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
  [String]$Path,

  # Non-mandatory Parameter
  [Parameter(Mandatory=$false,HelpMessage="Specifyc the folder to save the icon")]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({Test-Path -Path $_ -PathType Container})]
  [String]$Destination = "."
)
#endregion - Parameters

#region - Script Environment
#Requires -Version 5
# #Requires -RunAsAdministrator
Set-StrictMode -Version Latest
#endregion - Script Environment

#region - Functions
#endregion - Functions

#region - Main code
#-- Script variables --#
# PS v2+ = $scriptDir = split-path -path $MyInvocation.MyCommand.Path -parent
# PS v4+ = Use $PSScriptRoot for script path
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

#-- Main code --#
Write-Verbose -Message "Extracting icon from $($Path)"
$iconFile = Join-Path -Path (Convert-Path -Path $Destination) -ChildPath "$((Get-Item -Path $Path).BaseName).png"
$ico = [System.Drawing.icon]::ExtractAssociatedIcon($Path)
if ($ico) {
  # WhatIf example
  if ($PSCmdlet.ShouldProcess($iconFile, "Extract icon")) {
    Write-Verbose -Message "Saving extracted icon to $($iconFile)"
    $ico.ToBitmap().Save($iconFile, "png")
  }
}
#endregion - Main code
