<#
Gameplan voor dit scriptie:

[!] Definier al de benodigde Input
- win-ad-usersfromsql
  sqlsrv:   
  table: Default Quary takes everything in the Database 
  Action: Create, Update, Delete, Disable 
  variablen:
    !username: <'Naam'>
    !firstname: <'voornaam'>
    !lastname: <'Achternaam'>
    Password: <'Doekoe2020!'>
    !Enabled: <'Yes'> & <'No'> (PASSWORD MUST BE FILLED IN)
    !Location: 'OU'
  HomeFolder: yes
  Groups: [group1,group2,group3,group4]

  {  
  clearSQL: yes Or no #Moet de SQL table hierna gecleared worden
  UpdateSQL: Of moet deze geupdate worden met de nieuwe usernamen  
  }

[!] Definier Welke Input Afhankelijk is van wie
[!] Test De SQL server samen met de AD server
[!] Kijk ook of je meerdere Outputs kan doen in een action
    Out put Peruser zou opzig wel lekker zijn
[!][Countertje maken voor hoeveel users het uiteindelijk zijn geweest
Welke Al in het AD zaten en daarom dubel awren en een 01 fzo acher hun naam hebbe gekregen
[!]Eerste 4 letters van de achternaam gebruiken daarna de eerste 3 letters van hun voornaam
[!] IF username is al inebruik en dus dubbel verander dit ook direct in de SQL database
#>

#!powershell

$spec = @{
    options = @{
        sqlserver = @{ type = "str";        required = $true}
        query = @{ type = " str";           required = $true}
        action = @{ type = "str"; options = 'Create','Update','Delete','Disabled'; required = $true}
        variables = @{
            username = @{ type = "str";     required = $true}
            firstname = @{ type = "str";    required = $true}
            lastname = @{ type = "str";     required = $true}
            company = @{ type = "str" }
            OUpath = @{type = "str" }
            groups = @{type = "str" }
            enabled = @{type = "bool"; default = $false} 
            password = @{type = "str" }                            
        } 
    }
    required_if = @(
        ,@('Enabled',$True,@('password'))
    
    }
    
    $module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

    $sqlserver = $module.spec.sqlserver
    $query = $module.spec.query
    $action = $module.spec.action
    $username = $module.spec.variables.username
    $firstname = $module.spec.variables.firstname
    $lastname = $module.spec.variables.lastname
    $company = $module.spec.variables.company
    $OUpath = $module.spec.variables.OUpath
    $groups = $module.spec.variables.groups
    $enabled = $module.spec.variables.enabled
    $password = $module.spec.variables.password



    #test if Domaincontroller is active. 
    try {
        get-addomain
    }
    catch {
        $errormsg = $_.exception.message
    }
    $module.failjson("AD is not Availble and/or Active: $errormsg")


    #test Check if Sql server and data is achable Importante hopefully multiple Catches would be noc
    try {
        $data = Invoke-Sqlcmd -Query $query -ServerInstance $sqlserver
    }
    catch {
        
    }