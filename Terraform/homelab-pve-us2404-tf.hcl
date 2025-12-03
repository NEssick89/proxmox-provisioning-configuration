terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.86.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name     = "home"
  vm_id         = var.vm_id
  name          = var.vm_name
  description   = var.description
  tags          = var.tags
  bios          = "seabios"
  machine       = "1440fx"
  tablet_device = false

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  clone {
    node_name = "home"
    vm_id     = "900"
    full      = true
  }

  cpu {
    cores = 2
    type  = "host"
    numa  = false
  }

  memory {
    dedicated = 4096
    floating  = false
  }

  vga {
    type   = "std"
    memory = 16
  }

  dynamic "efi_disk" {
    for_each = (var.bios == "ovmf" ? [1] : [])
    content {
      datastore_id      = var.efi_disk_storage
      file_format       = var.efi_disk_format
      type              = var.efi_disk_type
      pre_enrolled_keys = var.efi_disk_pre_enrolled_keys
    }
  }

  network_device {
    model   = var.vnic_model
    bridge  = var.vnic_bridge
    vlan_id = var.vlan_tag
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.disk_storage
      interface    = disk.value.disk_interface
      size         = disk.value.disk_size
      file_format  = disk.value.disk_format
      cache        = disk.value.disk_cache
      iothread     = disk.value.disk_iothread
      ssd          = disk.value.disk_ssd
      discard      = disk.value.disk_discard
    }
  }

  # cloud-init config
  initialization {
    datastore_id         = var.ci_datastore_id
    meta_data_file_id    = var.ci_meta_data
    network_data_file_id = var.ci_network_data
    user_data_file_id    = var.ci_user_data
    vendor_data_file_id  = var.ci_vendor_data

    user_account {
      username = var.ci_user
      keys     = (var.ci_ssh_key != null ? [file("${var.ci_ssh_key}")] : null)
    }

    dns {
      domain  = var.ci_dns_domain
      servers = (var.ci_dns_server != null ? [var.ci_dns_server] : [])
    }

    ip_config {
      ipv4 {
        address = var.ci_ipv4_cidr
        gateway = var.ci_ipv4_gateway
      }
    }
  }

  # Cloud-init SSH keys will cause a forced replacement, this is expected
  # behavior see https://github.com/bpg/terraform-provider-proxmox/issues/373
  lifecycle {
    ignore_changes = [initialization["user_account"], ]
  }
}