param(
    [string]$ResourceGroupName = "mate-azure-task-2",
    [string]$VMName = "task2-vm",
    [string]$DiskName = "task3-data-disk",
    [string]$Location = "uksouth",
    [int]$DiskSizeGB = 64,
    [int]$Lun = 42,
    [string]$AdminUsername = "azureuser",
    [string]$SshKeyPath = "$HOME/.ssh/mate"
)

$ErrorActionPreference = "Stop"

# 1. Create the managed data disk (64 GB, Premium SSD, LRS, no zone)
$disk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -ErrorAction SilentlyContinue
if (-not $disk) {
    Write-Output "Creating managed disk '$DiskName'..."
    $diskConfig = New-AzDiskConfig -Location $Location -CreateOption Empty -DiskSizeGB $DiskSizeGB -SkuName Premium_LRS
    $disk = New-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Disk $diskConfig
} else {
    Write-Output "Disk '$DiskName' already exists, skipping creation."
}

# 2. Attach it to the VM at the required LUN
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
if (-not ($vm.StorageProfile.DataDisks | Where-Object { $_.Lun -eq $Lun })) {
    Write-Output "Attaching disk to VM '$VMName' at LUN $Lun..."
    Add-AzVMDataDisk -VM $vm -Name $DiskName -CreateOption Attach -ManagedDiskId $disk.Id -Lun $Lun | Out-Null
    Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm | Out-Null
} else {
    Write-Output "Disk already attached at LUN $Lun, skipping."
}

# 3. Resolve the VM's public FQDN for SSH/SCP
$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object { $_.VirtualMachine.Id -eq $vm.Id }
$pipName = Split-Path $nic.IpConfigurations[0].PublicIpAddress.Id -Leaf
$fqdn = (Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $pipName).DnsSettings.Fqdn
Write-Output "VM FQDN: $fqdn"

# 4. Partition, format (if needed) and mount the data disk on the VM
$remoteSetupScript = @'
set -e
DEV=$(lsblk -no NAME,SIZE | awk '$2=="64G"{print "/dev/"$1; exit}')
if [ -z "$(sudo lsblk -no FSTYPE ${DEV}1 2>/dev/null)" ]; then
  sudo parted $DEV --script mklabel gpt mkpart primary ext4 0% 100%
  sudo partprobe $DEV
  sudo udevadm settle
  sudo mkfs.ext4 -F ${DEV}1
fi
sudo mkdir -p /data
mountpoint -q /data || sudo mount ${DEV}1 /data
UUID=$(sudo blkid -s UUID -o value ${DEV}1)
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID   /data   ext4   defaults,nofail   1   2" | sudo tee -a /etc/fstab
sudo mkdir -p /data/app
sudo chown azureuser:azureuser /data/app
'@
Write-Output "Preparing data disk filesystem and mount point..."
$remoteSetupScript | ssh -i $SshKeyPath -o StrictHostKeyChecking=accept-new "$AdminUsername@$fqdn" "bash -s"

# 5. Deploy the application to the data disk
Write-Output "Copying application to /data/app..."
$repoRoot = Split-Path -Parent $PSScriptRoot
scp -i $SshKeyPath -o StrictHostKeyChecking=accept-new -r "$repoRoot/app/*" "${AdminUsername}@${fqdn}:/data/app"

# 6. Install dependencies and (re)configure the systemd service to run from /data/app
$remoteDeployScript = @'
set -e
sed -i "s/\r$//" /data/app/start.sh
sed -i "s/\r$//" /data/app/todoapp.service
chmod +x /data/app/start.sh
sudo apt-get update -y
sudo apt-get install -y python3-pip
sudo cp /data/app/todoapp.service /etc/systemd/system/todoapp.service
sudo systemctl daemon-reload
sudo systemctl enable todoapp
sudo systemctl restart todoapp
sleep 3
systemctl status todoapp --no-pager
'@
Write-Output "Installing dependencies and starting the service..."
$remoteDeployScript | ssh -i $SshKeyPath -o StrictHostKeyChecking=accept-new "$AdminUsername@$fqdn" "bash -s"

# 7. Verify the web application responds on port 8080
Write-Output "Verifying web application on port 8080..."
$response = Invoke-WebRequest -Uri "http://${fqdn}:8080/" -UseBasicParsing
Write-Output "HTTP status: $($response.StatusCode)"

Write-Output "Task 3 deployment complete."
