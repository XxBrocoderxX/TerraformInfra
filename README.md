# NCAE Cyber Competition Terraform Infrastructure Automation

This is a guide on how to use this terraform specific code. As of this current release,this is only proprietary to the personal physical Proxmox server, however you can change the necessary hard-coded variables.

## Prerequisites 

Install Terraform:


[Official HashiCorp installation page](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

On your Proxmox:

1. Create Terraform user and role with necessary permissions (will get updated soon)
2. Create a role for NCAE users to log into their dedicated infrastructure with necessary permissions (will get updated soon)
3. Have the NCAE infrastructure ready (will get updated soon)
4. Have the scoring engine and the hackathon router. The purpose of the hackathon router is to route all traffic to the internet from each individual NCAE topology's router instead of having a NAT bridge to the internet which defeats the purpose of configuring the router service (will get updated soon)

## How it works

### Create environment variables for the root user and the Terraform user (you made in the prerequisite)

Note: 
1. The Terraform user is used to create backups of every vm within the automated infrastructure made
2. The root user is necessary for Terraform to login to Proxmox (you can do your own research for why the root user is necessary :p not trying to be mean just saves lines on the README)

On your CLI, type:

```
export TF_VAR_PM_USER=ProxmoxTerraformUser
export TF_VAR_PM_PASS=ProxmoxTerraformPassword
export TF_VAR_PM_USER2=ProxmoxRootUser
export TF_VAR_PM_PASS2=ProxMoxRootPassword

```

### Prioritizing Workspace1.tfvars

When trying to create a new NCAE topology, create a copy of the Workspace1.tfvars file on your CLI:

```
cp Workspace1.tfvars Team1.tfvars
```
### Create Terraform workspace

For best practice, create a new workspace for each new infrastructure you want to make using terraform:

```
terraform workspace create Team1
terraform workspace select Team1
```

### Variables 

Inside the file you just made, you need to fill in the team number (change the $ sign)

```
IntIPSCHEME = "192.168.$.0/24"
IntBridge = "vmbrT$Int"
ExtIPSCHEME = "172.18.$.0/24"
ExtBridge = "vmbrT$Ext"
InternalRouter = "InternalRouterT$"
DNS = "DNST$"
FTPSSH = "FTPSSHT$"
Database = "DatabaseT$"
Web = "WebT$"
Pool = "Team$"
DNS_id = "$21"
Web_id = "$22"
Database_id = "$23"
InternalRouter_id = "$24"
FTPSSH_id = "$25"
hackathon_id = "$26"
hackathon_ip = "172.18.$.2/24"
dst_address = "192.168.$.0/24"
InternalRouterExt_ip = "172.18.$.1"
```
### Editing main.tf

There are a couple of hardcoded variables that you need to change:

1. within the ``` provider "proxmox" ``` resource, change the ``` endpoint ``` option to your server's proxmox API key or IP address
3. within the ```resource "proxmox_virtual_environment_acl" "operations_automation_monitoring"``` resource, change the ```role_id``` option to the role you created for the NCAE team user you made from prerequisites
4. within the resources listed below, specify the vm id of each service within the NCAE topology you already have in the prerequisites section inside the ```clone``` option:
   ```
   resource "proxmox_virtual_environment_vm" "DNS"
   resource "proxmox_virtual_environment_vm" "InternalRouter"
   resource "proxmox_virtual_environment_vm" "Web"
   resource "proxmox_virtual_environment_vm" "Database"
   resource "proxmox_virtual_environment_vm" "FTPSSH"
   resource "proxmox_virtual_environment_vm" "DNS"
   ```
5. Within the ``` resource "null_resource" "hackathon" ```, change the ```provisioner "local-exec"``` option to the private IP of the hackathon router you have in the prerequisites:
   ```
   provisioner "local-exec" {
    command = <<EOT
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@YOURHACKATHONIP"ip address add address=${self.triggers.hackathon_ip} interface=${self.triggers.hackathon_interface}"
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@YOURHACKATHONIP "ip route add dst-address=${self.triggers.dst_address} gateway=${self.triggers.InternalRouterExt_ip}"
    EOT
   }

   provisioner "local-exec" {
    when = destroy
    command = <<EOT
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@YOURHACKATHONIP "ip address remove [find address=\"${self.triggers.hackathon_ip}\" interface=\"${self.triggers.hackathon_interface}\"]"
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@YOURHACKATHONIP"ip route remove [find dst-address=\"${self.triggers.dst_address}\" gateway=\"${self.triggers.InternalRouterExt_ip}\"]"
    EOT
   }

   }

