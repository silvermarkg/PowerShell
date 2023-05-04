param(
  [Parameter(Mandatory=$true,Position=0)]
  [ValidateNotNullOrEmpty()]
  [int64]$PortNumber
)

# Update registry value with new port
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value $PortNumber 

# Add Windows Firewall rules
New-NetFirewallRule -DisplayName 'RDP (TCP-In)' -Profile 'Private' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $PortNumber -Service TermServ -RemoteAddress LocalSubnet 
New-NetFirewallRule -DisplayName 'RDP (UDP-In)' -Profile 'Private' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $PortNumber -Service TermServ -RemoteAddress LocalSubnet

# Disable default RDP rules
Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled False
