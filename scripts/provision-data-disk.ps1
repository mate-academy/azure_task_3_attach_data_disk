param(
    [string]$ResourceGroupName = "mate-azure-task-2",
    [string]$VmName,
    [string]$DiskName = "task3-data-disk",
    [int]$DiskSizeGB = 64,
    [int]$Lun = 42
)

$ErrorActionPreference = "Stop"

if ($DiskSizeGB -ne 64) {
    throw "This task requires a 64 GB data disk."
}

if ($Lun -ne 42) {
    throw "This task requires data disk LUN 42."
}

$vms = if ($VmName) {
    @(Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName)
} else {
    @(Get-AzVM -ResourceGroupName $ResourceGroupName)
}

if ($vms.Count -ne 1) {
    throw "Expected exactly one VM in resource group '$ResourceGroupName'; found $($vms.Count). Specify -VmName if necessary."
}

$vm = $vms[0]
$location = $vm.Location
$disk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -ErrorAction SilentlyContinue

if ($disk) {
    if ($disk.DiskSizeGB -ne $DiskSizeGB -or $disk.Sku.Name -ne "Premium_LRS" -or $disk.Location -ne $location -or $disk.Zones) {
        throw "Existing disk '$DiskName' does not match 64 GB Premium_LRS with no availability zone."
    }
    Write-Output "Using existing disk '$DiskName'."
} else {
    $diskConfig = New-AzDiskConfig `
        -Location $location `
        -CreateOption Empty `
        -DiskSizeGB $DiskSizeGB `
        -SkuName "Premium_LRS"
    $disk = New-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Disk $diskConfig
    Write-Output "Created disk '$DiskName'."
}

$attachedAtLun = @($vm.StorageProfile.DataDisks | Where-Object { $_.Lun -eq $Lun })
if ($attachedAtLun.Count -gt 1) {
    throw "More than one data disk is attached at LUN $Lun."
}

if ($attachedAtLun.Count -eq 1) {
    if ($attachedAtLun[0].ManagedDisk.Id -ne $disk.Id) {
        throw "LUN $Lun is already occupied by another disk."
    }
    Write-Output "Disk '$DiskName' is already attached at LUN $Lun."
} elseif (@($vm.StorageProfile.DataDisks | Where-Object { $_.ManagedDisk.Id -eq $disk.Id }).Count -gt 0) {
    throw "Disk '$DiskName' is attached at a different LUN. Detach it before retrying."
} else {
    $vm | Add-AzVMDataDisk -Name $DiskName -ManagedDiskId $disk.Id -Lun $Lun -CreateOption Attach
    Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm | Out-Null
    Write-Output "Attached disk '$DiskName' to VM '$($vm.Name)' at LUN $Lun."
}

Write-Output "Disk provisioning and attachment completed."
