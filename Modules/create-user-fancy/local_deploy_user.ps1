#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

<#
[X] Check for Active Directory things
[X] Check Look what kind of Action is taken to Create or to Remove A User
[X] Create an very simple user in Active Directory 
[] Put that User in a Certain Active Directory OU


#>



$spec = @{
    options = @{
        action = @{ type = "str"; choices= "create","remove"; required = $true}
        firstname = @{ type = "str"; required = $true}
        lastname = @{ type = "str"; required = $true}
        oupath = @{ type = "str";}
    }
}


$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

$action = $module.params.action
$givenname = $module.params.firstname
$surname = $module.params.lastname
$oupath = $module.params.oupath


$checkedAD = Get-ADDomainController -Erroraction SilentlyContinue
if (!$checkedAD) {
        $module.failjson("Active Directory Functions aren't reachable on target computer ; Creating/removing user will be aborted")
}

if (oupath){
    $checkedoupath = Get-ADOrganizationalUnit -Identity $oupath | select-object Distinguishedname -ErrorAction SilentlyContinue
    if(!$checkoupath){
        $module.failjson("Couldn't given ou path ; Creating/removing user will be aborted")
    }
}

 
if ($action -eq 'create') {
    $SamAccountName = $surname.substring(0.5) + $givenname.substring(0.3)
    if (Get-ADuser -Filter {SamAccountName -eq $SamAccountName}) {
        [int] $inc = 0    
        do {
            $inc ++
            $SamAccountName = $SamAccountName + [string]$inc
        }
        until (!(Get-ADuser -Filter {SamAccountName -eq "$SamAccountName"}))   
    
    }


    $user = New-ADUser `
        -givenname $givenname `
        -surname $surname `
        -name $SamAccountName `
        -SamAccountName $SamAccountName `
        -Path $checkedoupath
                        
}



elseif ($action -eq 'remove') {    
    
}


$module.Exitjson();