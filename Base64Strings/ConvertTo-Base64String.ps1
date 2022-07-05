<#
  Script:  Convert-Base64String.ps1
  Date:    18-Feb-2016
  Author:  Mark Goodman
  Version: 1.0
  
  This script is provided "AS IS" with no warranties, confers no rights and 
  is not supported by the authors.
#>

<#
    .SYNOPSIS
    Converts string to base64 string.

    .PARAMETER String
    The string you want to convert
	
    .EXAMPLE
    ConvertTo-Base64String -String MyString
	
	Description
	-----------
	Converts MyString to a base64 string
#>

<#  Parameters  #>
[cmdletbinding(SupportsShouldProcess=$true)]
param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$String
)

<# Script Environment #>
#Requires -Version 2
Set-StrictMode -Version Latest

<#  Functions  #>

<#  Script variables  #>
$scriptDir = split-path -path $MyInvocation.MyCommand.Path -parent

<#  Main code block  #>
$base64String = [System.Convert]::ToBase64String([System.Text.Encoding]::Default.GetBytes($String))
Write-Host -Object $base64String
