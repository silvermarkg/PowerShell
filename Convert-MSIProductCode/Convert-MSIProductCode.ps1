<#
Author: Mark Goodman
Date: 17-Jun-2022
Version: 1.0.0

Release Notes
-------------
Based on code from https://adameyob.com/2016/03/21/convert-program-guid-product-code/
#>

[CmdletBinding(DefaultParameterSetName="ProductCode")]
param (
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ProductCode")]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$")]
    [String]$ProductCode,

    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ProductID")]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^[0-9a-fA-F]{32}$")]
    [String]$ProductID
)

if ($PSBoundParameters.ContainsKey("ProductCode")) {
    # Convert ProductCode to ProductID
    $ProductCodeChars = [regex]::replace($ProductCode, "[^a-zA-Z0-9]", "")
    $RearrangedCharIndex = 7, 6, 5, 4, 3, 2, 1, 0, 11, 10, 9, 8, 15, 14, 13, 12, 17, 16, 19, 18, 21, 20, 23, 22, 25, 24, 27, 26, 29, 28, 31, 30
    Return -join ($RearrangedCharIndex | ForEach-Object { $ProductCodeChars[$_] })
}
elseif ($PSBoundParameters.ContainsKey("ProductID")) {
    # Convert ProductID to ProductCode
    $RearrangedCharIndex = 7, 6, 5, 4, 3, 2, 1, 0, 11, 10, 9, 8, 15, 14, 13, 12, 17, 16, 19, 18, 21, 20, 23, 22, 25, 24, 27, 26, 29, 28, 31, 30
    $Result = -join ($RearrangedCharIndex | ForEach-Object {
        if ($_ -eq 0 -or $_ -eq 8 -or $_ -eq 12 -or $_ -eq 18) {
            $ProductID[$_] + "-"
        }
        else {
            $ProductID[$_]
        }
    })
    Return "{" + $Result.toString() + "}"
}