[CmdletBinding()]
param()

# Get join status from dsregcmd
# Note: This has only been tested when running as a user, not as SYSTEM
# Note: There may be a better way but I've not found it yet.
$joinStatus = dsregcmd.exe /status

# Determine join status
if ($joinStatus -match "AzureADJoined : YES" -and $joinStatus -match "DomainJoined : YES") {
  $joinType = "Hybrid"
}
elseif ($joinStatus -match "AzureADJoined : YES" -and $joinStatus -match "DomainJoined : NO") {
  $joinType = "Cloud"
}
elseif ($joinStatus -match "AzureADJoined : NO" -and $joinStatus -match "DomainJoined : YES") {
  $joinType = "AD"
}
else {
  $joinType = "Workgroup"
}

# return result
return $joinType