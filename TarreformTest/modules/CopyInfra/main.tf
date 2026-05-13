terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.106.0"
    }
  }
}


provider "proxmox" {
    endpoint = "https://warriors.biscottibox.cc/api2/json"
    insecure = true
	  username = var.PM_USER
	  password = var.PM_PASS
} 

resource "proxmox_network_linux_bridge" "InternalBridge" {
  node_name = "pve"
  address   = var.IntIPSCHEME
  name      = var.IntBridge
}

resource "proxmox_network_linux_bridge" "ExternalBridge" {
  node_name = "pve"
  name      = var.ExtBridge
  address   = var.ExtIPSCHEME
}

resource "proxmox_virtual_environment_pool" "operations_pool" {
  pool_id = var.Pool
}

resource "proxmox_virtual_environment_vm" "DNS" {
  name      = var.DNS
  node_name = "pve"
  pool_id   = var.Pool
  vm_id   = var.DNS_id
  
  clone {
    vm_id = "105"
  }

  network_device {
    bridge = var.IntBridge
  } 
}

resource "proxmox_virtual_environment_vm" "InternalRouter" {
  name        = var.InternalRouter
  node_name = "pve"
  pool_id = var.Pool
  vm_id   = var.InternalRouter_id

  clone {
    vm_id = "107"
  }

  network_device {
    bridge = var.IntBridge
  }

  network_device {
    bridge = var.ExtBridge
  }

}

resource "proxmox_virtual_environment_vm" "Web" {
  name        = var.Web
  node_name = "pve"
  pool_id = var.Pool
  vm_id   = var.Web_id

  clone {
    vm_id = "131"
  }

  network_device {
    bridge = var.IntBridge
  }
}

resource "proxmox_virtual_environment_vm" "Database" {
  name      = var.Database
  node_name = "pve"
  pool_id = var.Pool
  vm_id   = var.Database_id

  clone {
    vm_id = "103"
  }

  network_device {
    bridge = var.IntBridge
  }
}

resource "proxmox_virtual_environment_vm" "FTPSSH" {
  name        = var.FTPSSH
  node_name = "pve"
  pool_id = var.Pool
  vm_id   = var.FTPSSH_id
  
  clone {
    vm_id = "104"
  }

  network_device {
    bridge = var.IntBridge
  }

  network_device {
    bridge = var.ExtBridge
  }

}

resource "null_resource" "hackathon" {
  
  depends_on = [
    null_resource.reload,
    proxmox_virtual_environment_vm.DNS,
    proxmox_virtual_environment_vm.InternalRouter,
    proxmox_virtual_environment_vm.Web,
    proxmox_virtual_environment_vm.FTPSSH,
    proxmox_virtual_environment_vm.Database

  ]
  

   triggers = {
    hackathon_ip = var.hackathon_ip
    hackathon_interface = var.hackathon_interface
    dst_address = var.dst_address
    InternalRouterExt_ip = var.InternalRouterExt_ip
   }
  provisioner "local-exec" {
    command = <<EOT
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@172.31.1.18 "ip address add address=${self.triggers.hackathon_ip} interface=${self.triggers.hackathon_interface}"
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@172.31.1.18 "ip route add dst-address=${self.triggers.dst_address} gateway=${self.triggers.InternalRouterExt_ip}"
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    command = <<EOT
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@172.31.1.18 "ip address remove [find address=\"${self.triggers.hackathon_ip}\" interface=\"${self.triggers.hackathon_interface}\"]"
      sshpass -p 'root' ssh -o StrictHostKeyChecking=no admin@172.31.1.18 "ip route remove [find dst-address=\"${self.triggers.dst_address}\" gateway=\"${self.triggers.InternalRouterExt_ip}\"]"
    EOT
  }

}
resource "null_resource" "reload" {

  depends_on = [
    proxmox_virtual_environment_vm.DNS,
    proxmox_virtual_environment_vm.InternalRouter,
    proxmox_virtual_environment_vm.Web,
    proxmox_virtual_environment_vm.FTPSSH,
    proxmox_virtual_environment_vm.Database,
  ]


  triggers = {
    ExtBridge = var.ExtBridge
    useruser = var.PM_USER2
    passwordpassword = var.PM_PASS2
    net = var.net_id
  }
 
  connection {
    type = "ssh"
    host = "172.31.1.2"
    user = self.triggers.useruser
    password = self.triggers.passwordpassword
  }

  provisioner "remote-exec" {
    inline = [
      "ifreload -a",
      "qm snapshot ${var.DNS_id} PRACTICESNAPSHOT", 
      "qm snapshot ${var.InternalRouter_id} PRACTICESNAPSHOT",
      "qm snapshot ${var.Web_id} PRACTICESNAPSHOT",
      "qm snapshot ${var.Database_id} PRACTICESNAPSHOT",
      "qm snapshot ${var.FTPSSH_id} PRACTICESNAPSHOT",
      "qm set 108 --${var.net_id} virtio,bridge=${var.ExtBridge}"
      #"qm importdisk 106 /mnt/backup/template/iso/chr-6.49.18.img VM-Store -format qcow2",
      #"qm set ${var.hackathon_id} --scsi0 VM-Store:106/vm-106-disk-0.qcow2",
      # "qm set ${var.hackathon_id}106 --boot order=scsi0"
    ]
  }
  provisioner "remote-exec" {
    when = destroy 
    inline = [
      "qm set 108 --delete ${self.triggers.net} "
      ]
    } 
}


