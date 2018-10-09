#https://github.com/solarwinds/OrionSDK/wiki/IPAM-API

<#
.EXAMPLE
.\AddDNS.ps1 -Recordname myapp -Recordip 192.168.0.139 -DNSServer 192.168.0.201 -DNSzone int.lab.local 

.SYNOPSIS
.\AddDNS.ps1 -Recordname myapp -Recordip 192.168.0.139 -DNSServer 192.168.0.201 -DNSzone int.lab.local
#>

Param(
  [string]$Recordname,
  [string]$Recordip,
  [string]$DNSServer,
  [string]$DNSzone
)

Add-PSSnapin SwisSnapin

$Username = "xxxxxx"
$Password = "xxxxxx"
$swis = Connect-Swis -username $Username -password $Password -Hostname 192.168.0.35

#Add DNS A record
Invoke-SwisVerb $swis IPAM.IPAddressManagement AddDnsARecord @($Recordname, $Recordip, $DNSServer, $DNSzone)

#Reserv IP address
Invoke-SwisVerb $swis IPAM.SubnetManagement ChangeIPStatus  @($Recordip, "Used")
