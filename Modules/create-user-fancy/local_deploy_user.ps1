#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

<#
[X] Check for Active Directory things
[X] Check Look what kind of Action is taken to Create or to Remove A User
[X] Create an very simple user in Active Directory 
[X] Put that User in a Certain Active Directory OU
[X] Persoonlijke folder


[Omgekeerd Process van dit]


#>



$spec = @{
    options = @{
        action = @{ type = "str"; choices= "create","remove"; required = $true}
        firstname = @{ type = "str"; required = $true}
        lastname = @{ type = "str"; required = $true}
        oupath = @{ type = "str";}
        sharepath = @{ type = "str";}
    }
}


$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

#Makes the Variables easier to use and more readable
$action = $module.params.action
$givenname = $module.params.firstname
$surname = $module.params.lastname
$oupath = $module.params.oupath

#checks for Active directory functions
$checkAD = Get-ADDomainController -Erroraction SilentlyContinue
if (!$checkAD) {
        $module.failjson("Active Directory Functions aren't reachable on target computer")
}

 
if ($action -eq 'create') {

    $SamAccountName = $surname.substring(0.5) + $givenname.substring(0.3)
    [int] $inc = 0 
    if (Get-ADuser -Filter {SamAccountName -eq $SamAccountName}) {
        do {
            $inc ++
            $SamAccountName = $SamAccountName + [string]$inc
        }
        until (!(Get-ADuser -Filter {SamAccountName -eq $SamAccountName}))   
    }

    $checkOU = Get-ADOrganizationalUnit -Identity $oupath -ErrorAction SilentlyContinue
    if(!$checkOU){
        $module.failjson("Couldn't find $oupath user $SamAccountName Creating user will be aborted")
    }

    New-ADUser `
        -givenname $givenname `
        -surname $surname `
        -name $SamAccountName `
        -SamAccountName $SamAccountName `
        -path $oupath
        -Userprofile 
        -ProfilePath "$sharepath\%SAMACCOUNTNAME%"
        -Homedrive "Z"
        -Homedirectory "$sharepath\%SAMACCOUNTNAME%"
                    

}



elseif ($action -eq 'remove') {    
    
}


$module.Exitjson();