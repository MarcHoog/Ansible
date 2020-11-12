<#

Copy Paste die 2 lijnen hieronder en het werkt



$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/MarcHoog/Ansible/master/PowershellModuleAnsible/AddtoDomain.ps1
Invoke-Expression $($ScriptFromGitHub.Content)

#>


$NewHostName = Read-Host -Prompt 'Input your new server name'  
$DomainToJoin = Read-Host -Prompt ' Input Domain you want to join' 
 
Add-Computer -DomainName $DomainToJoin -NewName $NewHostName -Restart