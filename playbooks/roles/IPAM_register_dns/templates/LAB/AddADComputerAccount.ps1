<#
.EXAMPLE
.\AddADComputerAccount.ps1 -CompHost SERVER01 -OU "APPS,ou=SERVERS,dc=lab,dc=local" -Role "NGINX Machine" 

.SYNOPSIS
.\AddADComputerAccount.ps1 -CompHost SERVER01 -OU "APPS,ou=SERVERS,dc=lab,dc=local" -Role "NGINX Machine"
#>


Param(
  [string]$CompHost,
  [string]$OU,
  [string]$Role
)

$password = "xxxxxx" | ConvertTo-SecureString -asPlainText -Force
$username = "LAB\creator"
$mycredentials = New-Object System.Management.Automation.PSCredential($username,$password)

$var01 = "cn=$CompHost,ou=$OU"
$var02 = $Role
$var03 = "cn=LINUX_ROOT_$CompHost,ou=Security Groups,dc=lab,dc=local"
$var04 = "Root access to Linux machine - $CompHost"

#Check if AD object exists
Invoke-Command -ComputerName dc11.lab.local -scriptBlock { param($myvar01,$myvar02,$myvar03,$myvar04,$mycred) 
$result = dsget computer $myvar01

If ($result) {

	write-host "DUPLICATED_OBJECT"

}

else {

	#Create computer account 
	dsadd computer $myvar01 

	#Reset computer account 
	dsmod computer $myvar01 -reset -desc $myvar02

	#Create root access group 
	dsadd group $myvar03 -desc $myvar04

}

#else {

#	#Create computer account
#	Invoke-Command -ComputerName dc11.lab.local -scriptBlock { param($a1,$mycred) 
#	dsadd computer $a1 
#	} -argumentList $myvar01 -credential $mycred

#	#Reset computer account
#	Invoke-Command -ComputerName dc11.lab.local -scriptBlock { param($a1,$a2,$mycred) 
#	dsmod computer $a1 -reset -desc $a2
#	} -argumentList $myvar01,$myvar02 -credential $mycred

#	#Create root access group
#	Invoke-Command -ComputerName dc11.lab.local -scriptBlock { param($a3,$a4,$mycred) 
#	dsadd group $a3 -desc $a4
#	} -argumentList $myvar03,$myvar04 -credential $mycred

#} 

} -argumentList $var01,$var02,$var03,$var04,$mycredentials -credential $mycredentials