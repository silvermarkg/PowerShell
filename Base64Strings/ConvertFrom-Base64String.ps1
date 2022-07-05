<#
  Script:  ConvertFrom-Base64String.ps1
  Date:    18-Feb-2016
  Author:  Mark Goodman
  Version: 1.0
  
  This script is provided "AS IS" with no warranties, confers no rights and 
  is not supported by the authors.
#>

<#
    .SYNOPSIS
    Converts base64 string to string.

    .PARAMETER Base64String
    The base64 string you want to convert
	
    .EXAMPLE
    ConvertFrom-Base64String -Base64String UG93ZXJTaGVsbA==
	
	Description
	-----------
	Converts UG93ZXJTaGVsbA== to a string (PowerShell)
#>

<#  Parameters  #>
[cmdletbinding(SupportsShouldProcess=$true)]
param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Base64String
)

<# Script Environment #>
#Requires -Version 2
Set-StrictMode -Version Latest

<#  Functions  #>

<#  Script variables  #>
$scriptDir = split-path -path $MyInvocation.MyCommand.Path -parent

<#  Main code block  #>
$string = [System.Text.Encoding]::Default.GetString([System.Convert]::FromBase64String($Base64String))
Write-Host -Object $string
