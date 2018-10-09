<#
.EXAMPLE
.\PRTGaddDevice.ps1 -CompHost SERVER01 -CompIP 192.168.0.139 -PRTGGroupID 159145 -os LINUX 

.SYNOPSIS
.\PRTGaddDevice.ps1 -CompHost SERVER01 -CompIP 192.168.0.139 -PRTGGroupID 159145 -os LINUX
#>

Param(
  [string]$CompHost,
  [string]$CompIP,
  [string]$PRTGGroupID,
  [string]$os
)

$username="xxxxxxxxx";
$passhash="xxxxxxxxx"
$addToMonitoring = 0
$newHostname = $CompHost
$ipaddress = $CompIP
$GroupID = $PRTGGroupID

if ($os -eq 'LINUX') {
	$cloneID=161717
}

if ($os -eq 'WINDOWS') {
	$cloneID=161280
}


## Clone device
## /api/duplicateobject.htm?id=id_of_device_to_clone&name=new_name&host=new_hostname_or_ip&targetid=id_of_target_group

## Set properties
##/api/setobjectproperty.htm?id=10214&name=name&value=anothernewname

## Start monitoring
## /api/pause.htm?id=10214&action=1 

$Web = Invoke-WebRequest -URI "https://192.168.0.34/api/table.json?output=json&columns=device&id=$GroupID&username=$username&passhash=$passhash"
$output = $Web.Content


if ($output -like ('*' + $newHostname + '*')) {
    $addToMonitoring = 0
    # it is already added, no action required
}
else {
    $addToMonitoring = 1
    # does not exist and needs to be added
}


if ($addToMonitoring -eq 1) {
    # Add device
    $Web1 = Invoke-WebRequest -URI "https://192.168.0.34/api/duplicateobject.htm?id=$cloneID&name=$newHostname&host=$ipaddress&targetid=$GroupID&username=$username&passhash=$passhash"
	$tmpObjectID = $Web1.Forms.Fields.hiddenloginurl
	$newObjectID = $tmpObjectID.Replace("/device.htm?id=","")

    # Wait until PRTG refreshes its database
	Start-sleep 10

    # Unpasue cloned device
	$Web1 = Invoke-WebRequest -URI "https://192.168.0.34/api/pause.htm?id=$newObjectID&action=1&username=$username&passhash=$passhash"

    # Return device ID
	$result = $newObjectID
	return $result
}

# If server is already monitored by PRTG
if ($addToMonitoring -eq 0) {
	return "DUPLICATED"
}

