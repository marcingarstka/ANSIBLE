#Example: .\MoveVdisk.ps1 -CompHost SEVMTSTHDD01 -vstore DS_DEV05_APIGW -vdisk "SEVMTSTHDD01.vmdk" -vdiskname2 "Hard disk 2"
Param(
  [string]$CompHost,
  [string]$vstore,
  [string]$vdisk,
  [string]$vdiskname2
)

#Import PowerCLI
. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 

#Connect to vCenter
Connect-VIServer -Server seplmovcs02.millecloud.local -User MilleCreator@vsphere.local -Password !QAZxsw2

#List disks
$disks = get-harddisk -VM $CompHost

foreach ($item in $disks) {
	if ($item.Name -eq $vdiskname2) {
		if ($item.Filename -eq "[$vstore] $CompHost/$vdisk") {
			return "DUPLICATED"
		}
		else {
			#Move vDisk
			Get-HardDisk -vm $CompHost | where {$_.Name -eq "$vdiskname2"} | Move-HardDisk -Datastore $vstore -confirm:$false
			return "CONNECTED"
		}
	}
}

#Disconnect from vCenter
Disconnect-VIServer -Server seplmovcs02.millecloud.local -confirm:$false
