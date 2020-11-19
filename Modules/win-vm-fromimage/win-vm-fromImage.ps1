#!powershell

$spec = @{
    options = @{
        Action = @{ type = "str"; options = 'Create','Delete'; required = $true} 
        VMname = @{ type = "str"; required = $true}
        VMgeneration = @{ type = "int"; options = 1, 2; default = 2}
        VMos = @{ type = "str"; options = 'Linux','Windows'; required = $true}
        VMlocation = @{ type = "str"; default = 'C:\Users\Public\Documents\Hyper-V\Virtual hard disks' }
        VMcpu = @{ type = "int"; default = 1}
        VMmemory = @{
            startupMemory = @{ type = "str"; default = 2GB}
            minimalMemory = @{ type = "str";}
            maximumMemory = @{ type = "str";}
        }
        VMswitch = @{ type = "str";}
        VMimage = @{
            imageName = @{type = "str";}
            imageFolder = @{type = "str"; default = 'C:\images'} 
        }
        machineOption = @{
            hostname = @{type = "str";}
        }
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

#Define the Arugments

$Action = $spec.Action
$VMname = $spec.VMname
$VMgeneration = $spec.VMgeneration
$VMos = $spec.$VMos
$VMlocation = $spec.VMlocation
$VMcpu = $spec.VMcpu

$startupMemory = $spec.startupMemory
$minimalMemory = $spec.minimalMemory
$maximumMemory = $spec.maximumMemory

$VMswitch = $spec.VMswitch
$imageName = $spec.imageName
$imageFolder = $spec.imageFolder





function test-hyperV{
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
    if($hyperv.State -ne "Enabled") {
        $module.FailJson("Hyper-V doesn't seem to be running on the Desginated Machine")
    }
}


function new-HyperVM{

    if(Test-Path -Path $VMLocation -eq $false){
        $module.FailJson("The path $Vmlocation doesn't excist")
    }

    $CheckVM = Get-VM -name $name -ErrorAction SilentlyContinue
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
        Set-VMProccer $VMname -Count $VMcpu 
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
            $errormsg = $_.exception.message
            $module.FailJson("there was an error message: $errormsg")

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
        if(!minimalMemory -or !maximumMemory){
            Set-VMMemory $VMname -DynamicMemoryEnabled $false -StartupBytes $startupMemory 
        }else {
            Set-VMMemory $VMname -DynamicMemoryEnabled $True -StartupBytes $startupMemory -MinimumBytes $minimalMemory -MaximumBytes $maximumMemory
        }    
    }
    catch {
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