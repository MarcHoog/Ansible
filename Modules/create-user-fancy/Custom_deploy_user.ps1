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
    }
}


$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)



$checkAD = Get-ADDomainController -Erroraction SilentlyContinue
if (!$checkAD) {
    $module.failjson("Active Directory Functions aren't reachable on target computer")
}

if ($module.params.action -eq 'create') {
    
    Write-Output "We will be creating a user"
    
}

elseif ($module.params.action -eq 'remove') {

    Write-Output "We will be Removing a user"
    
}


$module.Exitjson();