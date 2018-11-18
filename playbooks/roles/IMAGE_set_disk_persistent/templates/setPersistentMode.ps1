<#
.EXAMPLE
.\setPersistenMode.ps1 -CompHost SERVER01 -vdiskname2 "Hard disk 2"

.SYNOPSIS
.\setPersistenMode.ps1 -CompHost SERVER01 -vdiskname2 "Hard disk 2"
#>

Param(
  [string]$CompHost,
  [string]$vdiskname2
)

#Import PowerCLI
#. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"

#Connect to vCenter
Connect-VIServer -Server vcs01.lab.local -User administrator@vsphere.local -Password P@ssw0rd

#Set Persistent Mode
get-harddisk -VM $CompHost | where {$_.Name -eq "$vdiskname2"} | Set-Harddisk -Persistence "IndependentPersistent" -Confirm:$False

#Disconnect from vCenter
Disconnect-VIServer -Server vcs01.lab.local -confirm:$false