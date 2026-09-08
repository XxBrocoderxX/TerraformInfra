# NCAE Cyber Competition Terraform Infrastructure Automation

This is a guide on how to use this terraform specific code. As of this current release,this is only proprietary to the personal physical Proxmox server, however you can change the necessary hard-coded variables.

## Prerequisites 

Install Terraform:


[Official HashiCorp installation page](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

On your Proxmox:

Create Terraform user and role with necessary permissions (will get updated soon)
Create a role for NCAE users to log into their dedicated infrastructure with necessary permissions (will get updated soon)
Have the NCAE infrastructure ready (will get updated soon)

## How it works

### Create environment variables for the root user and the Terraform user (you made in the prerequisite)

Note: 
1. The Terraform user is used to create backups of every vm within the automated infrastructure made
2. The root user is necessary for Terraform to login to Proxmox (you can do your own research for why the root user is necessary :p not trying to be mean just saves lines on the README)

```
export TF_VAR_PM_USER=ProxmoxTerraformUser
export TF_VAR_PM_PASS=ProxmoxTerraformPassword
export TF_VAR_PM_USER2=ProxmoxRootUser
export TF_VAR_PM_PASS2=ProxMoxRootPassword

```

### Variables 

Inside the Workspace1.tfvars file, you need to fill in the team number (change the $ sign)

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

