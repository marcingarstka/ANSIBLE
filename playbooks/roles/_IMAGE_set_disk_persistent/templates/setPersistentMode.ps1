#Example: .\setPersistenMode.ps1 -CompHost SEVMTSTHDD01 -vdiskname2 "Hard disk 2"
Param(
  [string]$CompHost,
  [string]$vdiskname2
)

#Import PowerCLI
. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 

#Connect to vCenter
Connect-VIServer -Server seplmovcs02.millecloud.local -User MilleCreator@vsphere.local -Password !QAZxsw2

#Set Persistent Mode
get-harddisk -VM $CompHost | where {$_.Name -eq "$vdiskname2"} | Set-Harddisk -Persistence "IndependentPersistent" -Confirm:$False

#Disconnect from vCenter
Disconnect-VIServer -Server seplmovcs02.millecloud.local -confirm:$false