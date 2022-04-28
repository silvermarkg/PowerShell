<#
  .NOTES
  Author: Mark Goodman
  Twitter: @silvermakrg
  Version 1.00
  Date: dd-MMM-yyyy

  Release Notes
  -------------

  Update History
  --------------
  1.00 (dd-MMM-yyyy) - Initial script

  License
  -------
  MIT LICENSE
  
  Copyright (c) 2022 Mark Goodman (@silvermarkg)

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
  <Short description>

  .DESCRIPTION
  <Long description>

  .PARAMETER ParamName
  <parameter description>
	
  .EXAMPLE
  <ScriptName>.ps1
	
	Description
	-----------
	<example description>
#>

#region - Parameters
[Cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param(
  # Mandatory parameter
  [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$True,HelpMessage="",Position=0)]
  [ValidateNotNullOrEmpty()]
  [String]$Name,

  # Non-mandatory Parameter
  [Parameter(Mandatory=$false,HelpMessage="")]
  [String]$Name2
)
#endregion - Parameters

#region - Script Environment
#Requires -Version 5
# #Requires -RunAsAdministrator
Set-StrictMode -Version Latest
#endregion - Script Environment

#region - Functions
function Get-Something {
  <#
  .SYNOPSIS
  Describe the function here
  .DESCRIPTION
  Describe the function in more detail
  .EXAMPLE
  Give an example of how to use it
  .EXAMPLE
  Give another example of how to use it
  .PARAMETER computername
  The computer name to query. Just one.
  .PARAMETER logname
  The name of a file to write failed computer names to. Defaults to errors.txt.
  #>

  [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
  param
  (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="")]
      [ValidateNotNullOrEmpty()]
      [String[]]$Name
  )

  begin
  {
    #-- Begin code only runs once --#
  }

  process
  {
    #-- Process block --#
    write-verbose "Beginning process loop"

    foreach ($Item in $Name) {
      Write-Verbose "Processing $Item"

      # Following if statement handles the -WhatIf and -Confirm switches
      if ($PSCmdlet.ShouldProcess($Item)) {
        # use $Item here
      }
    }
  }
}
#endregion - Functions

#region - Main code
#-- Script variables --#
# PS v2+ = $scriptDir = split-path -path $MyInvocation.MyCommand.Path -parent
# PS v4+ = Use $PSScriptRoot for script path

#-- Main code --#

#endregion - Main code