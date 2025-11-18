# renovate: datasource=custom.ubuntuLinuxRelease

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
    token_id     = var.proxmox_token_id
    token_secret = var.proxmox_token_secret
    node         = var.proxmox_node

    iso_file         = "ubuntu-24.04.2-live-server-amd64.iso"
    iso_url          = "https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
    iso_checksum     = "file:https://old-releases.ubuntu.com/releases/24.04/SHA256SUMS"
    iso_storage_pool = var.proxmox_iso_storage
    storage_pool     = var.proxmox_disk_storage

    cores            = 2
    memory           = 4096
    disk_size        = "32G"
    
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
  ssh_timeout  = "20m"
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

