<#
.EXAMPLE
./FUDOaddServer.ps1 -CompHost SERVER01 -CompIP 192.168.0.139 -FUDOGroup WINDOWS 

.SYNOPSIS
./FUDOaddServer.ps1 -CompHost SERVER01 -CompIP 192.168.0.139 -FUDOGroup WINDOWS
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

$username="xxxxxxxxx"
$password="xxxxxxxxx"
$bind="192.168.0.33"
$CompHost=$CompHost.ToLower()

#### LISTENERS
## BASTION_SSH: 687198065894883355
## BASTION_RDP: 687198065894883343
## BASTION_NLA: 687198065894883339

#### SAFES (FUDOGroup)
## WINDOWS_SERVERS: 687198065894883331
## LINUX_SERVERS: 687198065894883333
## WINDOWS_NLA_SERVERS: 687198065894883337

if ($FUDOGroup -eq 'WINDOWS_SERVERS') {
	$safe_id="687198065894883331";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883343";
	$protocol_security="std";
}

if ($FUDOGroup -eq 'LINUX_SERVERS') {
	$safe_id="687198065894883333";	
	$protocol="ssh";
	$port=22;
	$mylistener="687198065894883355";
}

if ($FUDOGroup -eq 'STANDALONE_SERVERS') {
	$safe_id="687198065894883337";	
	$protocol="rdp";
	$port=3389;
	$mylistener="687198065894883339";
	$protocol_security="nla";
}


#### Start new connection session
$session_body = @{
   username=$username;
   password=$password;
}
$json = $session_body | ConvertTo-Json
$session_id = Invoke-RestMethod -uri "https://192.168.0.33/api/system/login" -Method POST -Body $json -ContentType "application/json"


#### Check if server already exist
$uri = 'https://192.168.0.33/api/system/servers?sessionid=' + $session_id.sessionid
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
	$uri = 'https://192.168.0.33/api/system/servers?sessionid=' + $session_id.sessionid
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
	$uri = 'https://192.168.0.33/api/system/accounts?sessionid=' + $session_id.sessionid
	$account_id = Invoke-RestMethod -uri $uri -Method POST -Body $json -ContentType 'application/json'

	#### Add server & account to safe
	$safe_body = @{
		listener_id=$mylistener;
		account_id=$account_id.id;
	}

	$json = $safe_body | ConvertTo-Json
	$uri = 'https://192.168.0.33/api/system/safes/' + $safe_id + '/account_listeners?sessionid=' + $session_id.sessionid
	$safe_add = Invoke-RestMethod -uri $uri -Method POST -Body $json -ContentType 'application/json'
	$safe_add | fl

	if ($safe_add.id -gt 1) {
		return "OK"
	}
	
	else {
		return "ERROR"
	}
}