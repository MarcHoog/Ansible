<#
Presteps that need to be Taken Before this is Gonna even Slichty Work. 
It's Smart To have an image around of the sort of VM you wanne Duplicate 

Create A base Instalation. 

Update the instalationn 

Put Everything on it that ya wanne have Remember it's a base don't not a full running system 

Command to clean the system:
    C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown /mode:vm

Store the VM somewhere the Hyper V server Can reach it 

#>

<#
####################################################STEPS################################################################
#Get input

#Check if Hyper-V is running

#Copy the Imagedisk And rename it to something to the VMname that has to be created

#Start the VM With Set input network bla bla bla 

#Give it A hostname

#And throw it in te domain by Parsing it right through the thing
#>

<#
####################################################CommandsThatIneed################################################################
To run this shit Straight from tha CLOUD!

$ScriptFromGitHub = <Linkie> 
Invoke-Expression $($ScriptFromGitHub.Content)


Copy item: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item?view=powershell-7.1 Example 3
Create an VM: https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v
Change the VM there HDD: https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vmharddiskdrive?view=win10-ps 
#>

$ImageName = 'ServerCore2019-gen2'
$ImageFolder = 'C:\image'
$VMname = 'swagbug'

$VMmem
    $VMminmem 
    $VMmaxmem

$VMGeneration

$VMLocation = 'C:\Users\Public\Documents\Hyper-V\Virtual hard disks\'


#Trim\ From Input links

#Checks If the Hyper V is enabled
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."
} else {
    Write-Host "Hyper-V is disabled."
    exit
}

#Checks If the Image Excists and gets it's full location
$ImagePath = Get-ChildItem -Path $ImageFolder -Filter  *.vhdx | Where-Object {$_.Name -eq "$ImageName.vhdx"}  | Select-Object FullName
if ($null -eq $ImagePath){
    Write-Host "Could not find $imageName.vhdx in the folder $ImageFolder"
    exit
} else {
    $ImagePath = $ImagePath.FullName 
}



#Create The VirtualMachine
try {
    New-VM -Name $VMname -ComputerName $VMname -Generation $VMGeneration   
    Add-VMHardDiskDrive -VMName Test -Path D:\VHDs\disk1.vhdx
    Set-VMMemory TestVM -DynamicMemoryEnabled $true -MinimumBytes 64MB -StartupBytes 256MB -MaximumBytes 2GB -Priority 80 -Buffer 25
}
catch {

    $errormsg = $_.exception.message
    Write-Host $errormsg
    
}


#Checks if the Image Already Excists if not Copy's the Images to the location the VM will be And gets the Location of the new drive 
$CheckExcistence = Get-ChildItem -Path $VMLocation | Where-Object {$_.Name -eq "$VMname.vhdx" -or $_.Name -eq "$VMname"} 
if ($null -ne $CheckExcistence){
    Write-Host "There is Already an VM with the name $VMname in the location $VMLocation"
} else {

    Copy-Item "$imagepath" -Destination "$VMLocation\$VMName.vhdx"
    $
    $VHDpath = $VHDPath.Fullname   

}
