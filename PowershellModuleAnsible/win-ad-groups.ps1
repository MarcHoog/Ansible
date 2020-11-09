#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        state = @{ type = "str";    required = $true   }
        member = @{ type = "str";   required = $true  }
        group = @{ type = "str";    required = $true  }
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

$state = $module.Params.state
$member = $module.Params.member
$group = $module.Params.group


$state = $state.ToString().ToLower()
If (($state -ne "present") -and ($state -ne "absent")) {
$module.FailJson("state is '$state'; must be 'present' or 'absent'")
}
$membertype = 'user'
    

$memberisuser = get-aduser -filter "name -eq '$member'"
if ($null -eq $memberisuser ){
    $membertype = 'group'
    $memberisgroup = get-adgroup -filter "name -eq '$member'"

    if ($null -eq $memberisgroup){
        $module.FailJson("$member is not a User Or Group Excisting in Active Directory.")
    }
}

 
$groupisthere = get-adgroup -filter "name -eq '$group'"
if ($groupisthere){
        
    $groupname = groupisthere.name 
}
else{
    $module.FailJson("$group Is not a excisting group in active Directory ")
}


$groupmembers = get-adgroupmembers -identity $groupname | select-Expandproperty name


if($state -eq 'absent'){
    if($groupmembers -contains $groupname){
        $module.result.msg = "The $membertype : $member; is already a part of the Group: $group"
    }
    else {
        Add-adGroupMember -idenentity $member -Members $groupname
        $module.result.changed = $true
        $module.result.msg = "The $membertype  : $member; Has been Added to the Group $group"
    }
}

        
elseif($State -eq 'present'){
    if($groupmembers -contains $groupname){
    Remove-adGroupMember -identity $member -members $group
    $module.result.changed = $true
    $module.result.msg = "The $membertype : $member; Has been removed from the group $group"
    }
    else {
        $module.result.msg = "The $membertype : $member; Was not part of the Group $group"
    }
}


$module.Exitjson();