#Example: .\AttachVDISK.ps1 -CompHost SEVMTSTHDD01 -vstore DS_DEV05_APIGW -vdisk "SEVMINTAPI01.vmdk" -vdiskname2 "Hard disk 2"
Param(
  [string]$CompHost,
  [string]$vstore,
  [string]$vdisk,
  [string]$vdiskname2
)

#Import PowerCLI
. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"

#Connect to vCenter
Connect-VIServer -Server seplmovcs02.millecloud.local -User MilleCreator@vsphere.local -Password !QAZxsw2 | out-null

#Attach disk if missing
$diskcount = get-harddisk -VM $CompHost | where {$_.Filename -eq "[$vstore] $CompHost/$vdisk"} 

if ($diskcount) {
	return "DUPLICATED"
}

else {
	$disk2 = New-HardDisk -vm $CompHost -DiskPath "[$vstore] $CompHost/$vdisk" -Persistence IndependentPersistent

	if ($disk2.Name -eq $vdiskname2) {
		return "CHANGED"
	}

	else {
		return "FAILED"
	}

}

#Disconnect from vCenter
Disconnect-VIServer -Server seplmovcs02.millecloud.local -confirm:$false