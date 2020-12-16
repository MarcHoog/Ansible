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
        groups = @{ type = "list";}
    }
}


$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

#Makes the Variables easier to use and more readable
$action = $module.params.action
$givenname = $module.params.firstname
$surname = $module.params.lastname
$oupath = $module.params.oupath
$sharepath = $module.params.sharepath
$groups = $module.params.groups

#checks for Active directory functions
$checkAD = Get-ADDomainController -Erroraction SilentlyContinue
if (!$checkAD) {
        $module.failjson("Active Directory Functions aren't reachable on target computer")
}

 
if ($action -eq 'create') {

    $TempSamAccountName = $surname.substring(0.5) + $givenname.substring(0.3)
    [int] $inc = 0 
    if (Get-ADuser -Filter {SamAccountName -eq $TempSamAccountName}) {
        do {
            $inc ++
            $SamAccountName = $TempSamAccountName + [string]$inc
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
        -userprincipalname "$SamAccountName@aspire.local" `
        -name $SamAccountName `
        -SamAccountName $SamAccountName `
        -path $oupath `
        -profilepath "$sharepath\%username%" `
        -Homedrive "Z" `
        -Homedirectory "$sharepath\%username%" `
        -AccountPassword (convertto-securestring "P@ssword123" -AsPlainText -Force) `
        -ChangePasswordAtLogon $True `
        -Enabled $True

    #Create his folder

    $user = $User = Get-ADUser -Identity $samAccountName

    $homeShare = New-Item -path $sharepath\$SamAccountName -ItemType Directory -Force
    $acl = get-acl $homeShare

    $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Full control"
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
 
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User.SID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    $acl.AddAccessRule($AccessRule)
 
    Set-Acl -Path $homeShare -AclObject $acl -ea Stop

    # Give the user Groups 

    write $groups

}



elseif ($action -eq 'remove') {    
    
}


$module.Exitjson();