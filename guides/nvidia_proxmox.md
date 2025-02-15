# Setting up NVIDIA Drivers on Proxmox VE with GPU Passthrough

This guide explains how to install and configure NVIDIA drivers on your Proxmox VE host and enable GPU passthrough to your virtual machines. This allows you to leverage the power of your NVIDIA GPU within your VMs for tasks like machine learning, gaming, or video editing.

## Prerequisites

---

![This is an image](https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logo2.png)

--- 


Before you begin, ensure you have the following:

* A Proxmox VE server with an NVIDIA GPU installed.
* Access to the Proxmox VE command line interface (CLI) via SSH.
* A basic understanding of Proxmox VE and virtual machine management.

## Installing the NVIDIA Driver on the Proxmox VE Host

This step involves installing the NVIDIA driver on your Proxmox VE host operating system. The exact steps may vary slightly depending on your Proxmox VE version and the specific NVIDIA GPU you are using. Consult the official NVIDIA documentation for the most up-to-date instructions.

Generally, you will need to download the appropriate driver package from the NVIDIA website and then install it using the package manager for your distribution.

## Enabling GPU Passthrough

Once the NVIDIA driver is installed, you need to enable GPU passthrough for your virtual machines. This involves assigning the GPU to a specific VM.

1. **Identify your GPU:** Use the `lspci` command to identify the PCI address of your NVIDIA GPU. The output will look something like this:

   ```bash
   01:00.0 VGA compatible controller: NVIDIA Corporation ...

