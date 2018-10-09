<#
.EXAMPLE
./FUDOaddServer.ps1 -CompHost SEVMQUAXXX99 -CompIP 10.208.201.165 -FUDOGroup STANDALONE_SERVERS 

.SYNOPSIS
./FUDOaddServer.ps1 -CompHost SEVMQUAXXX99 -CompIP 10.208.201.165 -FUDOGroup STANDALONE_SERVERS
#>

Param(
  [string]$CompHost,
  [string]$CompIP,
  [string]$FUDOGroup
)

####Force to use TLS 1.2 for web requests (default is 1.0)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

####Ignore self-signed certificates
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$username="api"
$password="!QAZxsw21qazXSW@"
$bind="10.208.1.205"
$CompHost=$CompHost.ToLower()

#### LISTENERS
## BASTION_SSH: 687198065894883355
## BASTION_RDP: 687198065894883343
## BASTION_NLA: 687198065894883339

#### SAFES (FUDOGroup)
## MILLECLOUD_PLDEV_SERVERS: 687198065894883331
## MILLECLOUD_PL_SERVERS: 687198065894883333
## MILLECLOUD_SERVERS: 687198065894883336
## PL_SERVERS: 687198065894883330
## ELIFE_SERVERS: 687198065894883334
## STANDALONE_SERVERS: 687198065894883335
## SSH: 687198065894883342


if ($FUDOGroup -eq 'MILLECLOUD_PLDEV_SERVERS') {
	$safe_id="687198065894883331";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883343";
	$protocol_security="std";
}

if ($FUDOGroup -eq 'MILLECLOUD_PL_SERVERS') {
	$safe_id="687198065894883333";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883343";
	$protocol_security="std";
}

if ($FUDOGroup -eq 'MILLECLOUD_SERVERS') {
	$safe_id="687198065894883336";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883343";
	$protocol_security="std";
}

if ($FUDOGroup -eq 'PL_SERVERS') {
	$safe_id="687198065894883330";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883343";
	$protocol_security="std";
}

if ($FUDOGroup -eq 'ELIFE_SERVERS') {
	$safe_id="687198065894883334";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883343";
	$protocol_security="std";
}

if ($FUDOGroup -eq 'STANDALONE_SERVERS') {
	$safe_id="687198065894883335";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883339";
	$protocol_security="nla";
}

if ($FUDOGroup -eq 'SSH') {
	$safe_id="687198065894883342";	
	$protocol="ssh";
	$port=22;
	$mylistener="687198065894883355";
}



#### Start new connection session
$session_body = @{
   username=$username;
   password=$password;
}
$json = $session_body | ConvertTo-Json
$session_id = Invoke-RestMethod -uri "https://10.208.1.205/api/system/login" -Method POST -Body $json -ContentType "application/json"


#### Check if server already exist
$uri = 'https://10.208.1.205/api/system/servers?sessionid=' + $session_id.sessionid
$server_list = Invoke-RestMethod -uri $uri -Method GET -ContentType 'application/json'
$server = $server_list | where {$_.Name -like '*' + $CompHost + '*'}

if ($server.id -gt 0) {

	return "DUPLICATED"

}

else {

	##### Add server RDP
	if ($protocol -eq "rdp") {
		$server_body = @{
			address=$CompIP;
			name=$CompHost;
			port=$port;
			protocol=$protocol;
			bind_ip=$bind;
			rdp = @{
				security=$protocol_security;
			}
		}
	}
	#### Add server SSH
	if ($protocol -eq "ssh") {
		$server_body = @{
			address=$CompIP;
			name=$CompHost;
			port=$port;
			protocol=$protocol;
			bind_ip=$bind;	
		}
	}	

	$json = $server_body | ConvertTo-Json
	$uri = 'https://10.208.1.205/api/system/servers?sessionid=' + $session_id.sessionid
	$server_id = Invoke-RestMethod -uri $uri -Method POST -Body $json -ContentType 'application/json'

	#### Add server account
	$server_account_body = @{
		credentials = @{
			login="";
			method="password";
			secret="";
		}
		server_id=$server_id.id;
		type="regular"
		name="at " + $CompHost;
	}

	$json = $server_account_body | ConvertTo-Json
	$uri = 'https://10.208.1.205/api/system/accounts?sessionid=' + $session_id.sessionid
	$account_id = Invoke-RestMethod -uri $uri -Method POST -Body $json -ContentType 'application/json'

	#### Add server & account to safe
	$safe_body = @{
		listener_id=$mylistener;
		account_id=$account_id.id;
	}

	$json = $safe_body | ConvertTo-Json
	$uri = 'https://10.208.1.205/api/system/safes/' + $safe_id + '/account_listeners?sessionid=' + $session_id.sessionid
	$safe_add = Invoke-RestMethod -uri $uri -Method POST -Body $json -ContentType 'application/json'
	$safe_add | fl

	if ($safe_add.id -gt 1) {
		return "OK"
	}
	
	else {
		return "ERROR"
	}
}