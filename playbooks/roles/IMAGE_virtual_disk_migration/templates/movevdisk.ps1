<#
.EXAMPLE
.\MoveVdisk.ps1 -CompHost SERVER01 -vstore DS_DEV05_APIGW -vdisk "SERVER01.vmdk" -vdiskname2 "Hard disk 2"

.SYNOPSIS
.\MoveVdisk.ps1 -CompHost SERVER01 -vstore DS_DEV05_APIGW -vdisk "SERVER01.vmdk" -vdiskname2 "Hard disk 2"
#>

#############################################################
### REQUIRES POWERCLI INSTALLATION ON THE VCENTER MACHINE ###
#############################################################

Param(
  [string]$CompHost,
  [string]$vstore,
  [string]$vdisk,
  [string]$vdiskname2
)

#Import PowerCLI
#. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"

#Connect to vCenter
Connect-VIServer -Server vcs01.lab.local -User administrator@vsphere.local -Password P@ssw0rd

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
Disconnect-VIServer -Server vcs01.lab.local -confirm:$false
