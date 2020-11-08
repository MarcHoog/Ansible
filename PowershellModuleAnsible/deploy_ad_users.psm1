ad-groupMembership {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_.GetType().FullName -eq 'Ansible.Basic.AnsibleModule' })]
        $Module,
    
        [Parameter(Mandatory=$true)]
        [String]$State = 'absent',

        [Parameter(Mandatory=$true)]
        [String[]]$member = $null,

        [Parameter(Mandatory=$true)]
        [String[]]$group = $null
    )

        $result = New-Object psobject;
        Set-Attr $result "changed" $false;
        Set-Attr $result "msg" "";
        

        $state = Get-Attr $params "state" "present"
        $state = $state.ToString().ToLower()
        If (($state -ne "present") -and ($state -ne "absent")) {
            Fail-Json $result.msg "state is '$state'; must be 'present' or 'absent'"
        }


        $membertype = 'user'
    
        $memberisuser = get-aduser -filter {(-name -eq $member)}
        if ($memberisuser -eq $null){
            $membertype = 'group'
            memberisgroup = get-adgroup -filter {(-name -eq $member)}

            if ($memberisgroup -eq $null){
             Fail-Json $result.msg "$member is not a User Or Group Excisting in Active Directory."
            }
        }

 
        $groupisthere = get-adgroup -filter {(-name - eq $group)}
        if ($groupisthere){
        
            $groupname = groupisthere.name 
        }
        else{
            Fail-Json $result.msg "$group Is not a excisting group in active Directory "
       }


       $groupmembers = get-adgroupmembers -identity $groupname | select-Expandproperty name


       if($state -eq 'absent'){
           if($groupmembers -contains $groupname){
                $result.msg = "The $membertype : $member; is already a part of the Group: $group"
            }
            else {
                Add-adGroupMember -idenentity $member -Members $groupname
                $result.changed = $true
                $result.msg = "The $membertype  : $member; Has been Added to the Group $group"
            }
        }

        
       elseif($State -eq 'present'){
            if($groupmembers -contains $groupname){
            Remove-adGroupMember -identity $member -members $group
            $result.changed = $true
            $result.msg = "The $membertype : $member; Has been removed from the group $group"
            }
            else {
                $result.msg = "The $membertype : $member; Was not part of the Group $group"
            }
        }


    Exit-json $result;

    }