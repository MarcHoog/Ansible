


[!]$VMname = 'swagbug'
[!]$VMLocation = 'C:\Users\Public\Documents\Hyper-V\Virtual hard disks'
[!]$VMcpu = 4
[!]$VMstartupmem = 1GB
    [?!!]$VMminmem = 64MB
    [?!!]$VMmaxmem = 2GB
[!]$VMGeneration = 2

[?]$NWadaptername = 'Infralab Intern 1'
[?]$ImageName = 'ServerCore2019-gen2'
[?]$ImageFolder = 'C:\image'

$spec = @{
    options = @{
        VMname = @{ type = "str";        required = $true}
        VMlocation = @{ type = " str";           required = $true}
        $VMcpu = @{ type = "str"; options = 'Create','Update','Delete','Disabled'; required = $true}
        variables = @{

    }
    required_if = @(
        ,@('Enabled',$True,@('password'))
    
    }
    
    $module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)


    #Checks If the Hyper V is enabled
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
    if($hyperv.State -eq "Enabled") {
        Write-Host "Hyper-V is enabled."
    } else {
        Write-Host "Hyper-V is disabled."
        exit
    }

    if ($VMLocation){
    $VmPath = New-Item -ItemType Directory -Path "$vmlocation\$vmname\Virtual Hard Disks\"
    $Vmpath = $VmPath.Fullname
    }


    if ($ImageFolder -and $imageName){

        $ImagePath = Get-ChildItem -Path $ImageFolder -Filter  *.vhdx | Where-Object {$_.Name -eq "$ImageName.vhdx"}  | Select-Object FullName

        if ($null -eq $ImagePath){
            Write-Host "Could not find $imageName.vhdx in the folder $ImageFolder"
            exit
        } else {
            $ImagePath = $ImagePath.FullName 
        }


        $CheckExcistence = Get-ChildItem -Path $VMLocation | Where-Object {$_.Name -eq "$VMname.vhdx" -or $_.Name -eq "$VMname"}

        if ($null -ne $CheckExcistence){
            Write-Host "There is Already an VM with the name $VMname in the location $VMLocation"
        } else {

            Copy-Item "$imagepath" -Destination "$VmPath\$VMName.vhdx"
            $VHDpath =  Get-ChildItem -Path $VmPath| Where-Object {$_.Name -eq "$VMname.vhdx"} 
            $VHDpath = $VHDPath.Fullname  

        }
    }


    try {
        New-VM -Name $VMname -Generation $VMGeneration

        if ($VMcpu){
        Set-VMProcessor $VMname -Count $VMcpu
        }

        if ($VHDpath){
        Add-VMHardDiskDrive -VMName $VMname -Path $VHDpath
        }

        if ($VMminmem -and $VMmaxmem){
            Set-VMMemory $VMname -DynamicMemoryEnabled $True -StartupBytes $VMstartupmem -MinimumBytes $VMminmem -MaximumBytes $VMmaxmem
        }
        else{
            Set-VMMemory $VMname -DynamicMemoryEnabled $false -StartupBytes $VMstartupmem 
        }

        if($NWadaptername){
        Get-VMNetworkAdapter -VMName $VMname | Connect-VMNetworkAdapter -SwitchName $NWadaptername
        }
    }
    catch {

        $errormsg = $_.exception.message
        Write-Host $errormsg
        
    }


