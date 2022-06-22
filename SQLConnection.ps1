param(
    [Parameter(Mandatory=$true,Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]$SQLServer,

    [Parameter(Mandatory=$true,Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]$Database,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Query,

    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential
)

if ($PSBoundParameters.ContainsKey("Credential")) {
    $Authentication = "User ID={0};Password={1}" -f $Credential.GetNetworkCredential().UserName, $Credential.GetNetworkCredential().password
}
else {
    $Authentication = "Integrated Security=true"
}

# Database Connection
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server={0};database={1};{2}' -f $SQLServer,$Database,$Authentication
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $Query
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$SqlConnection.Close()
return $Dataset.Tables[0] | Select-Object -Property *
