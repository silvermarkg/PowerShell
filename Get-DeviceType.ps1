<#
  .SYNOPSIS
  Determines the device type (Laptop, Desktop or VDI) from the ChassisTypes property of the Win32_SystemEnclosure class
  This is based on the code in ZTIGather.wsf from the Microsoft Deployment Toolkit.
  This is intended to be dot-sorced before running the Get-DeviceType function

  .NOTES
  Author: Mark Goodman
  Twitter: @silvermakrg
  Version 1.00
  Date: 30-Jun-2022

  Release Notes
  -------------

  Update History
  --------------
  1.00 (30-Jun-2022) - Initial script

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
#>

#region - Parameters
[Cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param()
#endregion - Parameters

#region - Script Environment
#Requires -Version 5
# #Requires -RunAsAdministrator
Set-StrictMode -Version Latest
#endregion - Script Environment

#region - Functions
function Get-DeviceType {
  <#
    .SYNOPSIS
    Determines the device type (Laptop or Desktop) from the ChassisTypes property of the Win32_SystemEnclosure class
    This is based on the code in ZTIGather.wsf from the Microsoft Deployment Toolkit
  #>

  [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
  param()

  #-- Define variables --#
  $DeviceType = $null
  
  # Determine device type from Win32_SystemEnclosure ChassisTypes
  $SystemEnclosureInstances = Get-CimInstance -ClassName Win32_SystemEnclosure
  foreach ($Instance in $SystemEnclosureInstances) {
    if ($Instance.ChassisTypes[0] -in "8", "9", "10", "11", "12", "14", "18", "21", "30", "31", "32") {
      $DeviceType = "Laptop"
    }
    elseif ($Instance.ChassisTypes[0] -in "3", "4", "5", "6", "7", "15", "16") {
      $DeviceType = "Desktop"
    }
    elseif ($Instance.ChassisTypes[0] -eq "1") {
      $DeviceType = "VDI"
    }
  }

  # Return result
  return $DeviceType
}
#endregion - Functions
