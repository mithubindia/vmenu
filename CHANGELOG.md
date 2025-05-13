## 2025-05-13

### Fixed

- **Startup Fix on Newer Proxmox Versions**\
  Fixed an issue where some recent Proxmox installations lacked the `/usr/local/bin` directory, causing errors when installing the execution menu. The script now creates the directory if it does not exist before downloading the main menu.\
  🙏 Thanks to **@danielmateos** for detecting and reporting this issue.

### Improved

- **Updated Lynis Installation Logic in Post-Install Settings**\
  The `install_lynis()` function was improved to always install the **latest version** of Lynis by cloning the official GitHub repository:
  ```
  https://github.com/CISOfy/lynis.git
  ```
  The installation process now ensures the latest version is always fetched and linked properly within the system path.

  🙏 Thanks to **@Kamunhas** for reporting this enhancement opportunity.

- **Balanced Memory Optimization for Low-Memory Systems**  
  Improved the default memory settings to better support systems with limited RAM. The previous configuration could prevent low-spec servers from booting. Now, a more balanced set of kernel parameters is used, and memory compaction is enabled if supported by the system.

  ```bash
  cat <<EOF | sudo tee /etc/sysctl.d/99-memory.conf
  # Balanced Memory Optimization
  vm.swappiness = 10
  vm.dirty_ratio = 15
  vm.dirty_background_ratio = 5
  vm.overcommit_memory = 1
  vm.max_map_count = 65530
  EOF

  # Enable memory compaction if supported by the system
  if [ -f /proc/sys/vm/compaction_proactiveness ]; then
    echo "vm.compaction_proactiveness = 20" | sudo tee -a /etc/sysctl.d/99-memory.conf
  fi

  # Apply settings
  sudo sysctl -p /etc/sysctl.d/99-memory.conf
  ```

  These values help maintain responsiveness and system stability even under constrained memory conditions.

  🙏 Thanks to **@chesspeto** for pointing out this issue and helping refine the optimization.


## 2025-05-04

### Added
- **Interactive Help & Info Menu**  
  Added a new script called `Help and Info`, which provides an interactive command reference menu for Proxmox VE through a dialog-based interface.  
  This tool offers users a quick way to browse and copy useful commands for managing and maintaining their Proxmox server, all in one centralized location.

  ![Help and Info Menu](https://macrimi.github.io/ProxMenux/help/help-info-menu.png)

  *Figure 1: Help and Info interactive command reference menu.*

- **Uninstaller for Post-Install Utilities**  
  A new script has been added to the **Post-Installation** menu, allowing users to uninstall utilities or packages that were previously installed through the post-install script.

### Improved
- **Utility Selection Menu in Post-Installation Script**  
  The `Install Common System Utilities` section now includes a menu where users can choose which utilities to install, instead of installing all by default. This gives more control over what gets added to the system.

- **Old PV Header Detection and Auto-Fix**  
  After updating the system, the post-update script now includes a security check for physical disks with outdated LVM PV (Physical Volume) headers.  
  This issue can occur when virtual machines have passthrough access to disks and unintentionally modify volume metadata. The script now detects and automatically updates these headers.  
  If any error occurs during the process, a warning is shown to the user.

- **Faster Translations in Menus**  
  Several post-installation menus with auto-translations have been optimized to reduce loading times and improve user experience.


## 2025-04-14

### Added
- **New Script: Disk Passthrough to a CT**
Introduced a new script that enables assigning a dedicated physical disk to a container (CT) in Proxmox VE.
This utility lists available physical disks (excluding system and mounted disks), allows the user to select a container and one disk, and then formats or reuses the disk before mounting it inside the CT at a specified path.
It supports detection of existing filesystems and ensures permissions are properly configured. Ideal for use cases such as Samba, Nextcloud, or video surveillance containers.

### Improved  
- Visual Identification of Disks for Passthrough to VMs
Enhanced the disk detection logic in the Disk Passthrough to a VM script by including visual indicators and metadata.
Disks now display tags like ⚠ In use, ⚠ RAID, ⚠ LVM, or ⚠ ZFS, making it easier to recognize their current status at a glance. This helps prevent selection mistakes and improves clarity for the user.

## 2025-03-24  
### Improved  
- Improved the logic for detecting physical disks in the **Disk Passthrough to a VM** script. Previously, the script would display disks that were already mounted in the system on some setups. This update ensures that only unmounted disks are shown in Proxmox, preventing confusion and potential conflicts.  

- This improvement ensures that disks already mounted or assigned to other VMs are excluded from the list of available disks, providing a more accurate and reliable selection process.

## [1.1.1] - 2025-03-21
### Improved
- Improved the logic of the post-install script to prevent overwriting or adding duplicate settings if similar settings are already configured by the user.
- Added a warning note to the documentation explaining that using different post-installation scripts is not recommended to avoid conflicts and duplicated settings.

### Added
- **Create Synology DSM VM**:  
  A new script that creates a VM to install Synology DSM. The script automates the process of downloading three different loaders with the option to use a custom loader provided by the user from the local storage options.  
  Additionally, it allows the use of both virtual and physical disks, which are automatically assigned by the script.  

  ![VM description](https://macrimi.github.io/ProxMenux/vm/synology/dsm_desc.png)
  
  *Figure 1: Synology DSM VM setup overview.*

- **New VM Creation Menu**:  
  A new menu has been created to enable VM creation from templates or custom scripts.

- **Main Menu Update**:  
  Added a new entry to the main menu for accessing the VM creation menu from templates or scripts.

## 2025-03-06
### Added
- Completed the web documentation section to expand information on updated scripts.

## [1.1.0] - 2025-03-04
### Added
- Created a customizable post-install script for Proxmox with 10 sections and 35 different selectable options.

## [1.0.7] - 2025-02-17
### Added
- Created a menu with essential scripts from the Proxmox VE Helper-Scripts community.

## [1.0.6] - 2025-02-10
### Added
- Added real-time translation support using Google Translate.
- Modified existing scripts to support multiple languages.
- Updated installation script to install and configure:
  - `jq` (for handling JSON data)
  - Python 3 and virtual environment (required for translations)
  - Google Translate (`googletrans`) (for multi-language support)
- Introduced support for the following languages:
  - English
  - Spanish
  - French
  - German
  - Italian
  - Portuguese
- Created a utility script for auxiliary functions that support the execution of menus and scripts.

## [1.0.5] - 2025-01-31
### Added
- Added the **Repair Network** script, which includes:
  - Verify Network
  - Show IP Information
- Created the **Network Menu** to manage network-related functions.

## [1.0.4] - 2025-01-20
### Added
- Created a script to add a passthrough disk to a VM.
- Created the **Storage Menu** to manage storage-related functions.

## [1.0.3] - 2025-01-13
### Added
- Created a script to import disk images into a VM.

## [1.0.2] - 2025-01-09
### Modified
- Updated the **Coral TPU configuration script** to:
  - Also include Intel iGPU setup.
  - Install GPU drivers for video surveillance applications to support VAAPI and QuickSync.
- Added a function to **uninstall ProxMenux**.

## [1.0.1] - 2025-01-03
### Added
- Created a script to add **Coral TPU support in an LXC** for use in video surveillance programs.

## [1.0.0] - 2024-12-18
### Added
- Initial release of **ProxMenux**.
- Created a script to add **Coral TPU drivers** to Proxmox.
