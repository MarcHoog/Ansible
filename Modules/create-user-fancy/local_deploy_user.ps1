#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

<#
[X] Check for Active Directory things
[X] Check Look what kind of Action is taken to Create or to Remove A User
[ ] Create an very simple user in Active Directory 


#>



$spec = @{
    options = @{
        action = @{ type = "str"; choices= "create","remove"; required = $true}
        firstname = @{ type = "str"; required = $true}
        lastname = @{ type = "str"; required = $true}
    }
}


$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)








$checkAD = Get-ADDomainController -Erroraction SilentlyContinue
if (!$checkAD) {
        $module.failjson("Active Directory Functions aren't reachable on target computer")
}

 
if ($module.params.action -eq 'create') {


    $SamAccountName = $module.params.firstname.Substring(0.5) + $module.params.lastname.Substring(0.3)

    [int] $inc = 0
    if (Get-ADuser -Filter {SamAccountName -eq "$SamAccountName"}) {    
        do {
            $inc ++
            $SamAccountName = $SamAccountName + [string]$inc
        }
        until (-not (Get-ADuser -Filter {SamAccountName -eq "$SamAccountName"}))   
    }
    
    New-ADUser `
        -Name $SamAccountName `
        -givenname $module.params.firstname `
        -surname  $module.params.lastname `
        -SamAccountname $SamAccountName
}



elseif ($module.params.action -eq 'remove') {    
    
}


$module.Exitjson();