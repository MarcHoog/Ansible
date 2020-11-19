#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic


$spec = @{
    options = @{
        Action = @{ type = "str"; choices = 'Create','Delete'; required = $true} 
        VMname = @{ type = "str"; required = $true}
        VMgeneration = @{ type = "int"; choices = 1, 2; default = 2}
        VMos = @{ type = "str"; choices = 'Linux','Windows'; required = $true}
        VMlocation = @{ type = "str"; default = 'C:\Users\Public\Documents\Hyper-V\Virtual hard disks' }
        VMcpu = @{ type = "int"; default = 1}
        startupMemory = @{ type = "str"; default = 2GB}
        minimalMemory = @{ type = "str";}
        maximumMemory = @{ type = "str";}
        VMswitch = @{ type = "str";}
        imageName = @{type = "str";}
        imageFolder = @{type = "str"; default = 'C:\image'} 
    }
}


$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

#Define the Arugments

$Action = $module.params.Action
$VMname = $module.params.VMname
$VMgeneration = $module.params.VMgeneration
$VMos = $module.params.VMos
$VMlocation = $module.params.VMlocation
$VMcpu = $module.params.VMcpu

$startupMemory = $module.params.startupMemory
$minimalMemory = $module.params.minimalMemory
$maximumMemory = $module.params.maximumMemory

$VMswitch = $module.params.VMswitch
$imageName = $module.params.imageName
$imageFolder = $module.params.imageFolder





function test-hyperV{
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
    if($hyperv.State -ne "Enabled") {
        $module.FailJson("Hyper-V doesn't seem to be running on the Desginated Machine")
    }
}


function new-HyperVM{

    #if(Test-Path -Path $VMLocation -eq $false){
    #    $module.FailJson("The path $Vmlocation doesn't excist")
    #}

    $CheckVM = Get-VM -name $VMname -ErrorAction SilentlyContinue
    $CheckVMHardisk = Get-ChildItem -Path $VMLocation | Where-Object {$_.Name -eq "$VMname.vhdx" -or $_.Name -eq "$VMname"}
    if($CheckVMHardisk -or $CheckVM){
        $module.FailJson("There is already an Disk or VM created with the name $VMname; This Script try's to Create Unique Names for easier management")
    }

    try {
        New-VM -name $VMname -Generation $VMGeneration -Path $VMLocation
    }
    catch {
        $errormsg = $_.exception.message
        $module.FailJson("there was an error message: $errormsg")
    }
}


function set-VCPU{
    try {
        Set-VMProcessor $VMname -Count $VMcpu 
    }
    catch {
        $errormsg = $_.exception.message
        $module.FailJson("there was an error setting the Virtual CPU: $errormsg")
        
    }
    
} 


function set-VHDFromImage{
    $ImagePath = Get-ChildItem -Path $ImageFolder -Filter  *.vhdx | Where-Object {$_.Name -eq "$ImageName.vhdx"}  | Select-Object FullName

        if (!$ImagePath){
            $module.FailJson("Coudl not find an image in $imageFolder called: $imageName")
        } else {
            $ImagePath = $ImagePath.FullName 
        }

        try {
            $VmPath = New-Item -ItemType Directory -Path "$vmlocation\$vmname\Virtual Hard Disks\"
            $Vmpath = $VmPath.Fullname

            Copy-Item "$imagepath" -Destination "$VmPath\$VMName.vhdx"
            $VHDpath =  Get-ChildItem -Path $VmPath| Where-Object {$_.Name -eq "$VMname.vhdx"} 
            $VHDpath = $VHDPath.Fullname
        }
        catch {
            $errormsg = $_.exception.message
            $module.FailJson("There was an problem with copying the VMDisk to the right location message: $errormsg") 
        }

        try {
            Add-VMHardDiskDrive -VMName $VMname -Path $VHDpath
        }
        catch {
            $module.FailJson("There was an error attaching the VirtualHardisk to the VM $VMname")
        }
        

}

function set-VRAM {
    try {
        if(!$minimalMemory -or !$maximumMemory){
            Set-VMMemory $VMname -DynamicMemoryEnabled $false -StartupBytes $startupMemory 
        }else {
            Set-VMMemory $VMname -DynamicMemoryEnabled $True -StartupBytes $startupMemory -MinimumBytes $minimalMemory -MaximumBytes $maximumMemory
        }    
    }
    catch {
        $errormsg = $_.exception.message
        $module.FailJson("there was an error setting the VM's ram; message: $errormsg") 
    }
       
}

function set-VSWITCH{
    try {
        Get-VMNetworkAdapter -VMName $VMname | Connect-VMNetworkAdapter -SwitchName $VMswitch
    }
    catch {
        $module.FailJson("There was an error settings the VM's network adapter: $errormsg") 
    }
    
}



if($Action -eq "Create"){
    test-hyperV
    new-HyperVM

    if($VMcpu){
        set-VCPU
    }
    if($imageName -and $imageFolder){
        set-VHDFromImage
    }
    if($startupMemory){
        set-VRAM
    }
    if($VMswitch){
        set-VSWITCH
    }


}
elseif ($Action -eq "Delete") {
    
}

$module.Exitjson();