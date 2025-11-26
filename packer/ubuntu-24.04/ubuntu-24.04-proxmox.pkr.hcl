# renovate: datasource=custom.ubuntuLinuxRelease

packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.1.0"
    }
  }
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_token_id" {
  type = string
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "home"
}

variable "proxmox_disk_storage" {
  type    = string
  default = "vm-storage"
}

variable "proxmox_iso_storage" {
  type    = string
  default = "local"
}

variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

source "proxmox-iso" "ubuntu_24_04" {
    vm_name = "ubuntu-24-04-template"
    
    proxmox_url  = var.proxmox_api_url
    username     = var.proxmox_token_id
    token        = var.proxmox_token_secret
    node         = var.proxmox_node

  boot_iso {  
    type             = "scsi"
    iso_url          = "https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-live-server-amd64.iso"
    iso_checksum     = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
    iso_storage_pool = var.proxmox_iso_storage
    unmount          = true
  }

    cores            = 2
    memory           = 4096
  
   disks {
      disk_size    = "32G"
      storage_pool = var.proxmox_disk_storage
      type         = "scsi"
    }
    
    http_directory = "./http/ubuntu"
    boot_wait      = "5s"
    
    boot_command = [
        "c<wait> ",
        "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
        "<enter><wait>",
        "initrd /casper/initrd",
        "<enter><wait>",
        "boot",
        "<enter>"
    ]
   network_adapters {
        model  = "virtio"
        bridge = "vmbr0"
   }
   
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"
}


build {
    name    = "ubuntu-24-04-template"
    sources = ["source.proxmox-iso.ubuntu_24_04"]
    
    provisioner "shell" {
        inline = [
            "cloud-init clean",
            "rm /etc/cloud/cloud.cfg.d/*",
            "userdel --remove --force packer || true"
        ]
    }
}

