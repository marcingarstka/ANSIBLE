#### Creating temp folder
New-Item -ItemType Directory -Force -Path c:\temp

#### Creating cert
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$env:computername.$env:userdnsdomain"

#### Exporting cert
Export-Certificate -Cert $Cert -FilePath C:\temp\cert

#### Importing cert
Import-Certificate -Filepath 'C:\temp\cert' -CertStoreLocation 'Cert:\LocalMachine\Root'

#### Enabling listener
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

#### Enabling local server firewall rule
New-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' -Name 'Windows Remote Management (HTTPS-In)' -Profile Any -LocalPort 5986 -Protocol TCP
