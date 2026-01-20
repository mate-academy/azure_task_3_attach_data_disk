# Attach Data Disk to The Azure Virtual Machine

Storing the web application on the OS disk might not be the best idea. Imagine that you need to set up a disk backup for your web app: if you are using the OS disk to store the web app, disk backup would include both the application and the operating system. Such backups would consume a lot of storage space, and it would be hard to restore them. The best practice is to segregate the OS and the application by using separate data disks for your application and application data. This way, you get better control over the resources allocated for your application and for its performance. 

In this task, you will practice working with data disks for Azure Virtual Machines and deploy a new version of the web application to a separate data disk. 

## Prerequisites

Before completing any task in the module, make sure that you followed all the steps described in the **Environment Setup** topic, in particular: 

1. Ensure you have an [Azure](https://azure.microsoft.com/en-us/free/) account and subscription.

2. Create a resource group called `mate-resources` in the Azure subscription.

3. In the `mate-resources` resource group, create a storage account (any name) and a `task-artifacts` container.

4. Install [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.4) on your computer. All tasks in this module use PowerShell 7. To run it in the terminal, execute the following command: 
    ```
    pwsh
    ```

5. Install [Azure module for PowerShell 7](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-11.3.0): 
    ```
    Install-Module -Name Az -Repository PSGallery -Force
    ```
If you are a Windows user, before running this command, please also run the following: 
    ```
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

6. Log in to your Azure account using PowerShell:
    ```
    Connect-AzAccount -TenantId <your Microsoft Entra ID tenant id>
    ```

## Requirements

In this task, you need to perform the following steps: 

1. Create and attach a data disk:

    1. Use the infrastructure you created in the [previous task](https://github.com/mate-academy/azure_task_2_create_a_vm). In the `mate-azure-task-2`, create a new managed disk, which meets the following requirements:

        - size: 64 GB
        - type: Premium SSD
        - replication type: LRS
        - No infrastructure redundancy

    2. Attach the data disk to the virtual machine you created in the [previous task](https://github.com/mate-academy/azure_task_2_create_a_vm). When attaching the data disk, make sure that you **set LUN to 42**.

    3. Follow the [documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal?tabs=ubuntu#connect-to-the-linux-vm-to-mount-the-new-disk) to create the file system and mount the disk to the virtual machine. Mount disk to the folder `/data`.

2. Deploy the **new version**  of the web application to the virtual machine
    
    1. Connect to the VM using SSH, create a folder `/data/app`, and configure your user as an owned of the folder:
        ```
            ssh <your-vm-username>@<your-public-ip-DNS-name>
            sudo mkdir /data/app
            sudo chown <your-vm-username>:<your-vm-username> /data/app
        ```

    2. Form your computer, copy the content of the folder `app` to your virtual machine (run the command in the folder of this repository): 
        
        ```
            scp -r app/* <your-vm-username>@<your-public-ip-DNS-name>:/data/app
        ```

    3. Connect to the virtual machine again using SSH, install pre-requirements, and configure a service for the application
        
        ```
            sudo apt install python3-pip
            cd /data/app
            sudo mv todoapp.service /etc/systemd/system/
            sudo systemctl daemon-reload
            sudo systemctl restart todoapp
        ```
    
    4. Verify that the web app service is running. For that, run the following command on the VM: 
        
        ```
            systemctl status todoapp
        ```

3. Verify that the web application is running; for that, open in a web browser the following URL: `http://<your-public-ip-DNS-name>:8080`. You should see the main page of the todo app. 

4. Run artifacts generation script `scripts/generate-artifacts.ps1`

5. Test yourself using the script `scripts/validate-artifacts.ps1`

6. Submit the solution for a review

7. When the solution is validated, stop the virtual machine. 

## How to Complete Tasks in This Module 

Tasks in this module are relying on 2 PowerShell scripts: 

- `scripts/generate-artifacts.ps1` generates the task  “artifacts”  and uploads them to cloud storage. An  “artifact” is evidence of a task completed by you. Each task will have its own script, which will gather the required artifacts. The script also adds a link to the generated artifact in the `artifacts.json` file in this repository — make sure to commit changes to this file after you run the script. 
- `scripts/validate-artifacts.ps1` validates the artifacts generated by the first script. It loads information about the task artifacts from the `artifacts.json` file.

Here is how to complete tasks in this module:

1. Clone task repository

2. Make sure you completed the steps described in the Prerequisites section

3. Complete the task described in the Requirements section 

4. Run `scripts/generate-artifacts.ps1` to generate task artifacts. The script will update the file `artifacts.json` in this repo. 

5. Run `scripts/validate-artifacts.ps1` to test yourself. If tests are failing — follow the recommendation from the test script error message to fix or re-deploy your infrastructure. When you are ready to test yourself again — **re-generate the artifacts** (step 4) and re-run tests again. 

6. When all tests will pass — commit your changes and submit the solution for review. 

Pro tip: If you are stuck with any of the implementation steps, run `scripts/generate-artifacts.ps1` and `scripts/validate-artifacts.ps1`. The validation script might give you a hint on what to do.  
