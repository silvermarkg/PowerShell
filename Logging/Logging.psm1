<#
    Script:  Logging.psm1
    Date:    27-Jul-2022
    Author:  Mark Goodman
    Version: 1.21

    This script is provided "AS IS" with no warranties, confers no rights and 
    is not supported by the authors.

    Update history
    --------------
    1.21 - Fixed issue with Write-LogEntry not using Path parameter
    1.20 - Fixed issues when not specifying the Path parameter
    1.10 - Added additional options and validation
    1.00 - Initial version

#>

<#
    .SYNOPSIS
    Provides reusable functions for logging.

    .DESCRIPTION
    The logging function (Write-LogEntry) can write a log file in either basic format or CMTrace format.

    .EXAMPLE
    Import-Module -Name Logging.ps1
    Set-LogPath -Path "C:\Windows\Temp\MyScript.log"
    Write-LogEntry -Message "Script started"

    Description
    -----------
    The first line imports the module. The next line sets the path to the log file and the final line wrties an entry (in basic format) to the log file.

    .EXAMPLE
    Import-Module -Name Logging.ps1
    Set-LogPath -Path "C:\Windows\Temp\MyScript.log"
    Write-LogEntry -Message "Script started" -CMTraceFormat

    Description
    -----------
    The first line imports the module. The next line sets the path to the log file and the final line wrties an entry (in CMTrace format) to the log file.

    .EXAMPLE
    Import-Module -Name Logging.ps1
    $Path = "C:\Windows\Temp\MyScript.log"
    Write-LogEntry -Message "Script started" -Path $Path

    Description
    -----------
    The first line imports the module.
    The second line sets the Path variable.
    The thrid line writes to the log file by specifing the Path parameter

    .EXAMPLE
    Import-Module -Name Logging.ps1
    $LogPath = "C:\Windows\Temp\MyScript.log"
    Write-LogEntry -Message "Script started"

    Description
    -----------
    The first line imports the module.
    The second line sets the LogPath variable.
    The thrid line writes to the log file. No Path parameter is required as the $Script:LogPath variable value will be used.
#>

#-- Script Environment --#
#Requires -Version 4
Set-StrictMode -Version Latest

#-- Module variables --#
# PS v2+ = $scriptDir = split-path -path $MyInvocation.MyCommand.Path -parent
# PS v4+ = User $PSScriptRoot for script path
$LogPath = $null

#-- Functions  --#
function Get-LogPath {
<#
    .SYNOPSIS
    Gets the full path to the log file.
    Note: If the log path has not been set this returns null
#>

    #-- Parameters --#
    [cmdletbinding()]
    param ()

    # return log path
    return $Script:LogPath
}

function Set-LogPath {
<#
    .SYNOPSIS
    Sets the full path to the log file.
#>

    #-- Parameters --#
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, HelpMessage="Specifies the full path of the log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Set log path
    $Script:LogPath = $Path
}

function Write-LogEntry {
    <#
		.SYNOPSIS
		Writes a message to a log file.

		.DESCRIPTION
		Writes an infomational, warning or error meesage to a log file. Log entries can be written in basic (default) or cmtrace format.
    When using basic format, you can choose to include a date/time stamp if required.

		.PARAMETER Message
		THe message to write to the log file

		.PARAMETER Severity
		The severity of message to write to the log file. This can be Information, Warning or Error. Defaults to Information.

		.PARAMETER Path
		The path to the log file. Recommended to use Set-LogPath to set the path.

		#.PARAMETER AddDateTime (currently not supported)
		Adds a datetime stamp to each entry in the format YYYY-MM-DD HH:mm:ss.fff

		.EXAMPLE
    Write-LogEntry -Message "Searching for file" -Severity Information -Path C:\MyLog.log 

    Description
    -----------
    Writes a basic log entry

    .EXAMPLE
    Write-LogEntry -Message "Searching for file" -Severity Warning -LogPath C:\MyLog.log -CMTraceFormat 

    Description
    -----------
    Writes a CMTrace format log entry

		.EXAMPLE
    $Script:LogPath = "C:\MyLog.log"
    Write-LogEntry -Message "Searching for file" -Severity Information 

    Description
    -----------
    First line creates the script variable LogPath
    Second line writes to the log file.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$Message,

        [Parameter(Mandatory=$false,Position=1,HelpMessage="Severity for the log entry (Information, Warning or Error)")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Information", "Warning", "Error")]
        [String]$Severity = "Information",

        [Parameter(Mandatory=$false,Position=2,HelpMessage="The full path of the log file that the entry will written to")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Path -Path $_.Substring(0, $_.LastIndexOf("\")) -PathType Container) -and (Test-Path -Path $_ -PathType Leaf -IsValid)})]
        [String]$Path = $Script:LogPath,

        [Parameter(ParameterSetName="CMTraceFormat",HelpMessage="Indicates to use cmtrace compatible logging")]
        [Switch]$CMTraceFormat

        <# Currently not supported - basic log entries will include datetime stamp
        [Parameter(ParameterSetName="BasicDateTime",HelpMessage="Indicated to add datetime to basic log entry")]
        [Switch]$AddDateTime
        #>
    )

    # Construct date and time for log entry (based on currnent culture)
    $Date = Get-Date -Format (Get-Culture).DateTimeFormat.ShortDatePattern
    $Time = Get-Date -Format (Get-Culture).DateTimeFormat.LongTimePattern.Replace("ss", "ss.fff")

    # Determine parameter set
    if ($CMTraceFormat) {
        # Convert severity value
        switch ($Severity) {
            "Information" {
                $CMSeverity = 1
            }
            "Warning" {
                $CMSeverity = 2
            }
            "Error" {
                $CMSeverity = 3
            }
        }

        # Construct components for log entry
        $Component = (Get-PSCallStack)[1].Command
        $ScriptFile = $MyInvocation.ScriptName
  
        # Construct context for CM log entry
        $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        $LogText = "<![LOG[$($Message)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""$($Component)"" context=""$($Context)"" type=""$($CMSeverity)"" thread=""$($PID)"" file=""$($ScriptFile)"">"
    }
    else {
        # Construct basic log entry
        # AddDateTime parameter currently not supported
        #if ($AddDateTime) {
            $LogText = "[{0} {1}] {2}: {3}" -f $Date, $Time, $Severity, $Message
        #}
        #else {
        #    $LogText = "{0}: {1}" -f $Severity, $Message
        #}
    }

    # Add value to log file
    try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $Path -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to $($Path) file. Error message: $($_.Exception.Message)"
    }
}


#-- Exports --#
Export-ModuleMember -Function *Log*
