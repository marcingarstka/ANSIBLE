#https://github.com/solarwinds/OrionSDK/wiki/IPAM-API

<#
.EXAMPLE
.\AddHostname.ps1 -CompHost SERVER01 -CompIP 192.168.0.139 -DNSServer 192.168.0.201 -DNSDomain lab.local 

.SYNOPSIS
.\AddHostname.ps1 -CompHost SERVER01 -CompIP 192.168.0.139 -DNSServer 192.168.0.201 -DNSDomain lab.local
#>

Param(
  [string]$CompHost,
  [string]$CompIP,
  [string]$DNSServer,
  [string]$DNSDomain
)

$CompHostFull = $CompHost+"."+$DNSDomain

Add-PSSnapin SwisSnapin

$Username = "xxxxxx"
$Password = "xxxxxx"
$swis = Connect-Swis -username $Username -password $Password -Hostname 192.168.0.35

#Add DNS A record
Invoke-SwisVerb $swis IPAM.IPAddressManagement AddDnsARecord @($CompHostFull, $CompIP, $DNSServer, $DNSDomain)

#Reserv IP address
Invoke-SwisVerb $swis IPAM.SubnetManagement ChangeIPStatus  @($CompIP, "Used")
