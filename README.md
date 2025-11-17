# proxmox-provisioning-configuration
Proxmox Provisioning and Configuration

This repository contains automation assets for building, provisioning, and configuring virtual machines in a Proxmox environment. It uses a staged workflow involving image creation, infrastructure provisioning, and post-provision configuration.

Components
Packer

Used to build standardized Ubuntu 24.04 base images with cloud-init enabled.
The packer/ directory will contain:

Packer templates (*.pkr.hcl)

Variable definitions

Cloud-init user-data and meta-data files

Terraform

Planned integration for provisioning Proxmox VMs from the Packer-generated template, defining:

VM resources

CPU, memory, and storage parameters

Network assignments

Cloud-init injection

Ansible

Planned integration for post-provision configuration, including:

Package installation

Service configuration

Host-level settings
