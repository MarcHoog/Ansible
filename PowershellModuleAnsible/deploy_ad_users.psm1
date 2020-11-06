Invoke-MyServiceResource {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_.GetType().FullName -eq 'Ansible.Basic.AnsibleModule' })]
        $Module,

        [Parameter(Mandatory=$true)]
        [String]$Path = '',
        
        [Parameter(Mandatory=$true)]
        [String]$Task = ''
    )

 