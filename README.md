# ✅ Azure Task 3 – Attach Data Disk

## 🔧 Overview
Мета завдання — створити, приєднати та змонтувати додатковий диск до віртуальної машини в Azure.

---

## 🖥️ Virtual Machine Information
- VM Name: matevm  
- Resource Group: MATE-AZURE-TASK-2  
- Location: UK South  
- OS: Ubuntu 22.04 LTS  
- Username: vetal  
- Public IP: 20.68.219.223  

---

## 💽 Data Disk Information
- Disk Name: app-data-disk-uksouth  
- Size: 64 GB  
- Type: Premium_LRS  
- LUN: 42  
- Mount Point: /data

---

## ⚙️ Steps Performed

### 1️⃣ Create and Attach Disk (PowerShell on local machine)
```powershell
$rg = "MATE-AZURE-TASK-2"
$vmName = "matevm"
$loc = "uksouth"
$diskName = "app-data-disk-uksouth"

# Create disk
$diskCfg = New-AzDiskConfig -Location $loc -CreateOption Empty -DiskSizeGB 64 -SkuName Premium_LRS
New-AzDisk -ResourceGroupName $rg -DiskName $diskName -Disk $diskCfg

# Attach disk to VM
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
$disk = Get-AzDisk -ResourceGroupName $rg -DiskName $diskName
$vm = Add-AzVMDataDisk -VM $vm -Name $disk.Name -ManagedDiskId $disk.Id -Lun 42 -CreateOption Attach
Update-AzVM -ResourceGroupName $rg -VM $vm