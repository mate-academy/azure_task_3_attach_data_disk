param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
    [bool]$DownloadArtifacts=$true
)


# default script values 
$taskName = "task3"

$artifactsConfigPath = "$PWD/artifacts.json"
$resourcesTemplateName = "exported-template.json"
$tempFolderPath = "$PWD/temp"

if ($DownloadArtifacts) { 
    Write-Output "Reading config" 
    $artifactsConfig = Get-Content -Path $artifactsConfigPath | ConvertFrom-Json 

    Write-Output "Checking if temp folder exists"
    if (-not (Test-Path "$tempFolderPath")) { 
        Write-Output "Temp folder does not exist, creating..."
        New-Item -ItemType Directory -Path $tempFolderPath
    }

    Write-Output "Downloading artifacts"

    if (-not $artifactsConfig.resourcesTemplate) { 
        throw "Artifact config value 'resourcesTemplate' is empty! Please make sure that you executed the script 'scripts/generate-artifacts.ps1', and commited your changes"
    } 
    Invoke-WebRequest -Uri $artifactsConfig.resourcesTemplate -OutFile "$tempFolderPath/$resourcesTemplateName" -UseBasicParsing

}

Write-Output "Validating artifacts"
$TemplateFileText = [System.IO.File]::ReadAllText("$tempFolderPath/$resourcesTemplateName")
$TemplateObject = ConvertFrom-Json $TemplateFileText -AsHashtable

$virtualMachine = ( $TemplateObject.resources | Where-Object -Property type -EQ "Microsoft.Compute/virtualMachines" )
if ($virtualMachine) {
    if ($virtualMachine.name.Count -eq 1) { 
        Write-Output "`u{2705} Checked if Virtual Machine exists - OK."
    }  else { 
        Write-Output `u{1F914}
        throw "More than one Virtual Machine resource was found in the VM resource group. Please delete all un-used VMs and try again."
    }
} else {
    Write-Output `u{1F914}
    throw "Unable to find Virtual Machine in the task resource group. Please make sure that you created the Virtual Machine and try again."
}

if ($virtualMachine.location -eq "uksouth" ) { 
    Write-Output "`u{2705} Checked Virtual Machine location - OK."
} else { 
    Write-Output `u{1F914}
    throw "Virtual is not deployed to the UK South region. Please re-deploy VM to the UK South region and try again."
}

if (-not $virtualMachine.zones) { 
    Write-Output "`u{2705} Checked Virtual Machine availability zone - OK."
} else {
    Write-Output `u{1F914}
    throw "Virtual machine has availibility zone set. Please re-deploy VM with 'No infrastructure redundancy' availability option and try again." 
}

if (-not $virtualMachine.properties.securityProfile) { 
    Write-Output "`u{2705} Checked Virtual Machine security type settings - OK."
} else { 
    Write-Output `u{1F914}
    throw "Virtual machine security type is set to TMP or Confidential. Please re-deploy VM with security type set to 'Standard' and try again."
}

if ($virtualMachine.properties.storageProfile.imageReference.publisher -eq "canonical") { 
    Write-Output "`u{2705} Checked Virtual Machine OS image publisher - OK" 
} else { 
    Write-Output `u{1F914}
    throw "Virtual Machine uses OS image from unknown published. Please re-deploy the VM using OS image from publisher 'Cannonical' and try again."
}
if ($virtualMachine.properties.storageProfile.imageReference.offer.Contains('ubuntu-server') -and $virtualMachine.properties.storageProfile.imageReference.sku.Contains('22_04')) { 
    Write-Output "`u{2705} Checked Virtual Machine OS image offer - OK"
} else { 
    Write-Output `u{1F914}
    throw "Virtual Machine uses wrong OS image. Please re-deploy VM using Ubuntu Server 22.04 and try again" 
}

if ($virtualMachine.properties.hardwareProfile.vmSize -eq "Standard_B1s") { 
    Write-Output "`u{2705} Checked Virtual Machine size - OK"
} else { 
    Write-Output `u{1F914}
    throw "Virtual Machine size is not set to B1s. Please re-deploy VM with size set to B1s and try again."
}

if ($virtualMachine.properties.osProfile.linuxConfiguration.disablePasswordAuthentication -eq $true) { 
    Write-Output "`u{2705} Checked Virtual Machine OS user authentification settings - OK"
} else { 
    Write-Output `u{1F914}
    throw "Virtual Machine uses password authentification. Please re-deploy VM using SSH key authentification for the OS admin user and try again. "
}


$pip = ( $TemplateObject.resources | Where-Object -Property type -EQ "Microsoft.Network/publicIPAddresses")
if ($pip) {
    if ($pip.name.Count -eq 1) { 
        Write-Output "`u{2705} Checked if the Public IP resource exists - OK"
    }  else { 
        Write-Output `u{1F914}
        throw "More than one Public IP resource was found in the VM resource group. Please delete all un-used Public IP address resources and try again."
    }
} else {
    Write-Output `u{1F914}
    throw "Unable to find Public IP address resouce. Please create a Public IP resouce (Basic SKU, dynamic IP allocation) and try again."
}

if ($pip.properties.dnsSettings.domainNameLabel) { 
    Write-Output "`u{2705} Checked Public IP DNS label - OK"
} else { 
    Write-Output `u{1F914}
    throw "Unable to verify the Public IP DNS label. Please create the DNS label for your public IP and try again."
}


$nic = ( $TemplateObject.resources | Where-Object -Property type -EQ "Microsoft.Network/networkInterfaces")
if ($nic) {
    if ($nic.name.Count -eq 1) { 
        Write-Output "`u{2705} Checked if the Network Interface resource exists - OK"
    }  else { 
        Write-Output `u{1F914}
        throw "More than one Network Interface resource was found in the VM resource group. Please delete all un-used Network Interface resources and try again."
    }
} else {
    Write-Output `u{1F914}
    throw "Unable to find Network Interface resouce. Please re-deploy the VM and try again."
}

if ($nic.properties.ipConfigurations.Count -eq 1) { 
    if ($nic.properties.ipConfigurations.properties.publicIPAddress -and $nic.properties.ipConfigurations.properties.publicIPAddress.id) { 
        Write-Output "`u{2705} Checked if Public IP assigned to the VM - OK"
    } else { 
        Write-Output `u{1F914}
        throw "Unable to verify Public IP configuratio for the VM. Please make sure that IP configuration of the VM network interface has public IP address configured and try again."
    }
} else {
    Write-Output `u{1F914}
    throw "Unable to verify IP configuration of the Network Interface. Please make sure that you have 1 IP configuration of the VM network interface and try again."
}


$nsg = ( $TemplateObject.resources | Where-Object -Property type -EQ "Microsoft.Network/networkSecurityGroups")
if ($nsg) {
    if ($nsg.name.Count -eq 1) { 
        Write-Output "`u{2705} Checked if the Network Security Group resource exists - OK"
    }  else { 
        Write-Output `u{1F914}
        throw "More than one Network Security Group resource was found in the VM resource group. Please delete all un-used Network Security Group resources and try again."
    }
} else {
    Write-Output `u{1F914}
    throw "Unable to find Network Security Group resouce. Please re-deploy the VM and try again."
}

$sshNsgRule = ( $nsg.properties.securityRules | Where-Object { ($_.properties.destinationPortRange -eq '22') -and ($_.properties.access -eq 'Allow')} ) 
if ($sshNsgRule)  {
    Write-Output "`u{2705} Checked if NSG has SSH network security rule configured - OK"
} else { 
    Write-Output `u{1F914}
    throw "Unable to fing network security group rule which allows SSH connection. Please check if you configured VM Network Security Group to allow connections on 22 TCP port and try again."
}

$httpNsgRule = ( $nsg.properties.securityRules | Where-Object { ($_.properties.destinationPortRange -eq '8080') -and ($_.properties.access -eq 'Allow')} ) 
if ($httpNsgRule)  {
    Write-Output "`u{2705} Checked if NSG has HTTP network security rule configured - OK"
} else { 
    Write-Output `u{1F914}
    throw "Unable to fing network security group rule which allows HTTP connection. Please check if you configured VM Network Security Group to allow connections on 8080 TCP port and try again."
}


if ($virtualMachine.properties.storageProfile.dataDisks.Count -eq 1) { 
    Write-Output "`u{2705} Checked if data disk is attached to VM - OK"
} else { 
    throw "Unable to veryfy data disk. Expected attached data disks - 1, found - $($virtualMachine.properties.storageProfile.dataDisks.Count). Please make sure that you have one and only one data disk attached to VM and try again." 
}

$dataDisk = $virtualMachine.properties.storageProfile.dataDisks[0]
if ($dataDisk.lun -eq 42) { 
    Write-Output "`u{2705} Checked if data disk has a proper LUN - OK"
} else { 
    throw "Unable to verify data disk LUN. Expected - 42, got - $($dataDisk.lun). Please delete the virtual machine and create it again or follow the documentation for deataching data disk: https://learn.microsoft.com/en-us/powershell/module/az.compute/remove-azvmdatadisk?view=azps-11.4.0. After that, attach data disk to the VM using lun '42' and try again. "
}
if ($dataDisk.diskSizeGB -eq 64) { 
    Write-Output "`u{2705} Checked disk size - OK"
} else { 
    throw "Unable to verify data disk size. Expected - 64, got - $($dataDisk.diskSizeGB). Please delete the virtual machine and create it again or follow the documentation for deataching data disk: https://learn.microsoft.com/en-us/powershell/module/az.compute/remove-azvmdatadisk?view=azps-11.4.0. After that, delete the data disk resource, create a new one with the size of 64GB, attach it to the VM and try again."
}
if ($dataDisk.managedDisk.storageAccountType -eq 'Premium_LRS') { 
    Write-Output "`u{2705} Checked if premium disk is used - OK"
} else { 
    throw "Unable to verify data disk type (Premium or Standard). Please delete the virtual machine and create it again or follow the documentation for deataching data disk: https://learn.microsoft.com/en-us/powershell/module/az.compute/remove-azvmdatadisk?view=azps-11.4.0. After that, delete the data disk resource, create a new one with the type 'Premium SSD LRS', attach it to the VM and try again."
}

# Check the log from the script, which supposed to be started by the new version 
# of the todo app systemd unit config file: azure_task_3_attach_data_disk/app/start.sh. 
# There are 2 possible solutions for this task here: 
# 1-st solution. The expected output should look like this: 
# 
# NAME    HCTL        SIZE MOUNTPOINT
# loop0              63.9M /snap/core20/2182
# loop1                87M /snap/lxd/27428
# loop2              39.1M /snap/snapd/21184
# sda     1:0:0:42     64G        <--- that the first of 2 lines we are looking for, it proves that disk with LUN 42 is mounted
# └─sda1               64G /data           
# sdb     0:0:0:0      30G 
# ├─sdb1             29.9G /
# ├─sdb14               4M 
# └─sdb15             106M /boot/efi
# sdc     0:0:0:1       4G 
# └─sdc1                4G /mnt
#
# 2-nd solution. The expected output should look like this: 
# 
# NAME    HCTL        SIZE MOUNTPOINT
# loop0              63.9M /snap/core20/2182
# loop1                87M /snap/lxd/27428
# loop2              39.1M /snap/snapd/21184
# sda     1:0:0:42     64G /data                <--- that the line we are looking for, it proves that disk with LUN 42 is mounted
# └─sda1               64G 
# sdb     0:0:0:0      30G 
# ├─sdb1             29.9G /
# ├─sdb14               4M 
# └─sdb15             106M /boot/efi
# sdc     0:0:0:1       4G 
# └─sdc1                4G /mnt
# 
# To find 2 lines (for the first possible solution) and 1 line (for the second possible solution), we will 
# use regular expressions bellow. Feel free to test how they work using an online tool: https://regexr.com/
$lsblkRegex1 = '[a-z]{3}[ ]{1,}\d:\d:\d:42[ ]{1,}64G[ ]{1,}\n└─[a-z]{3}\d[ ]{1,}64G[ ]{1,}\/data'
$lsblkRegex2 = '[a-z]{3}[ ]{1,}\d:\d:\d:42[ ]{1,}64G[ ]{1,}\/data'
$response = (Invoke-WebRequest -Uri "http://$($pip.properties.dnsSettings.fqdn):8080/static/files/task3.log" -ErrorAction SilentlyContinue -SkipHttpErrorCheck) 
if ($response) { 
    Write-Output "`u{2705} Checked if the web application is running - OK"
    
    if ($response.StatusCode -eq 404) { 
        throw "Unable to verify that the new version of the todo app was deployed to the VM. Please make sure that you deployed the new version of the application to the server, and try to re-run validation script again."
    }

    if ($response.StatusCode -ne 200) { 
        throw "Unexpected error, unable to verify that the web app is configured properly. Please check the configuration of your web application and ensure, that the HTTP request to the following URL returnts HTTP status code 200 and try to re-run validation script again: http://$($pip.properties.dnsSettings.fqdn):8080/static/files/task4.log"
    }

    $taskLogContent = [System.Text.Encoding]::UTF8.GetString($response.Content)
    if ($taskLogContent.Contains("default")) { 
        throw "Unable to verify the new version of the web app. Please make sure that the new version of the dodo app is deployed to the VM, that new systemd unit config file is deployed, that you restarted the service after the systemd config file update and try again."
    }

    if ($taskLogContent -match $lsblkRegex1 -or $taskLogContent -match $lsblkRegex2) { 
        Write-Output "`u{2705} Checked if the disk is mounted to the VM - OK"
    } else { 
        throw "Unable to verify that the file system was created on the data disk, and that it's mounted to the VM. Please mount the disk to the VM, restart the todoapp service and try again."
    }

} else {
    throw "Unable to get a reponse from the web app. Please make sure that the VM and web application are running and try again."
}

Write-Output ""
Write-Output "`u{1F973} Congratulations! All tests passed!"