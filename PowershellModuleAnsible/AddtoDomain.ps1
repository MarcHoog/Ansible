$NewHostName = Read-Host -Prompt 'Input your new server name'  
$DomainToJoin = Read-Host -Prompt ' Input Domain you want to join' 
 
Add-Computer -DomainName $DomainToJoin -NewName $NewHostName -Restart