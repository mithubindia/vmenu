## 2025-07-01

### New version v1.1.3

![Installer Menu](https://macrimi.github.io/vmenu/install/install.png)

- **Dual Installation Modes for vmenu**  
  The installer now offers two distinct modes:  
  1. **Lite version (no translations):** Only installs two official Debian packages (`dialog`, `jq`) to enable menus and JSON parsing. No files are written beyond the configuration directory.  
  2. **Full version (with translations):** Uses a virtual environment and allows selecting the interface language during installation.  

  When updating, if the user switches from full to lite, the old version will be **automatically removed** for a clean transition.

### Added

- **New Script: Automated Post-Installation Setup**  
  A new minimal post-install script that performs essential setup automatically:  
  - System upgrade and sync  
  - Remove enterprise banner  
  - Optimize APT, journald, logrotate, system limits  
  - Improve kernel panic handling, memory settings, entropy, network  
  - Add `.bashrc` tweaks and **Log2RAM auto-install** (if SSD/M.2 is detected)

- **New Function: Log2RAM Configuration**  
  Now available in both the customizable and automatic post-install scripts.  
  On systems with SSD/NVMe, Log2RAM is **enabled automatically** to preserve disk life.

- **New Menus:**
  - 🧰 **System Utilities Menu**  
    Lets users select and install useful CLI tools with proper command validation.
  - 🌐 **Network Configuration & Repair**  
    A new interactive menu for analyzing and repairing network interfaces.

### Improved

- **Post-Install Menu Logic**  
  Options are now grouped more logically for better usability.

- **VM Creation Menu**  
  Enhanced with improved CPU model support and custom options.

- **UUP Dump ISO Creator Script**  
  - Added option to **customize the temporary folder location**  
  - Fixed issue where entire temp folder was deleted instead of just contents  
    💡 Suggested by [@igrokit](https://github.com/igrokit)  
    [#17](https://github.com/MacRimi/vmenu/issues/17), [#11](https://github.com/MacRimi/vmenu/issues/11)

- **Physical Disk to LXC Script**  
  Now handles **XFS-formatted disks** correctly.  
  Thanks to [@antroxin](https://github.com/antroxin) for reporting and testing!

- **System Utilities Installer**  
  Rewritten to **verify command availability** after installation, ensuring tools work as expected.  
  🐛 Fix for [#18](https://github.com/MacRimi/vmenu/issues/18) by [@DST73](https://github.com/DST73)

### Fixed

- **Enable IOMMU on ZFS**  
  The detection and configuration for enabling IOMMU on ZFS-based systems is now fully functional.  
  🐛 Fix for [#15](https://github.com/MacRimi/vmenu/issues/15) by [@troponaut](https://github.com/troponaut)

### Other

- Performance and code cleanup improvements across several modules.



## 2025-06-06

### Added

- **New Menu: Virtuliser PVE Helper Scripts**  
  Officially introduced the new **Virtuliser PVE Helper Scripts** menu, replacing the previous: Esenciales Virtuliser.  
  This new menu includes:
  - Script search by name in real time
  - Category-based browsing

  It’s a cleaner, faster, and more functional way to access community scripts in Virtuliser.

  ![Helper Scripts Menu](https://macrimi.github.io/vmenu/menu-helpers-script.png)


- **New CPU Models in VM Creation**  
  The CPU selection menu in VM creation has been greatly expanded to support advanced QEMU and x86-64 CPU profiles.  
  This allows better compatibility with modern guest systems and fine-tuning performance for specific workloads, including nested virtualization and hardware-assisted features.


  ![CPU Config](https://macrimi.github.io/vmenu/vm/config-cpu.png)

  Thanks to **@Nida Légé (Nidouille)** for suggesting this enhancement.


- **Support for `.raw` Disk Images**  
  The disk import tool for VMs now supports `.raw` files, in addition to `.img`, `.qcow2`, and `.vmdk`.  
  This improves compatibility when working with disk exports from other hypervisors or backup tools.

  💡 Suggested by **@guilloking** in [GitHub Issue #5](https://github.com/MacRimi/vmenu/issues/5)


- **Locale Detection in Language Skipping**  
  The function that disables extra APT languages now includes:
  - Automatic locale detection (`LANG`)
  - Auto-generation of `en_US.UTF-8` if none is found
  - Prevents warnings during script execution due to undefined locale


### Improved

- **APT Language Skipping Logic**  
  Improved locale handling ensures system compatibility before disabling translations:
  ```bash
  if ! locale -a | grep -qi "^${default_locale//-/_}$"; then
      echo "$default_locale UTF-8" >> /etc/locale.gen
      locale-gen "$default_locale"
  fi
  ```

- **System Update Speed**  
  Post-install system upgrades are now faster:  
  - The upgrade process (`dist-upgrade`) is separated from container template index updates.
  - Index refresh is now an optional feature selected in the script.



## 2025-05-27

### Fixed
- **Kali Linux ISO URL Updated**  
  Fixed the incorrect download URL for Kali Linux ISO in the Linux installer module. The new correct path is:  
  ```
  https://cdimage.kali.org/kali-2025.1c/kali-linux-2025.1c-installer-amd64.iso
  ```

### Improved
- **Faster Dialog Menu Transitions**  
  Improved UI responsiveness across all interactive menus by replacing `whiptail` with `dialog`, offering faster transitions and smoother navigation.

- **Coral USB Support in LXC**  
  Improved the logic for configuring Coral USB TPU passthrough into LXC containers:
  - Refactored configuration into modular blocks with better structure and inline comments.
  - Clear separation of Coral USB (`/dev/coral`) and Coral M.2 (`/dev/apex_0`) logic.
  - Maintains backward compatibility with existing LXC configurations.
  - Introduced persistent Coral USB passthrough using a udev rule:
    ```bash
    # Create udev rule for Coral USB
    SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="9302", MODE="0666", TAG+="uaccess", SYMLINK+="coral"
    
    # Map /dev/coral if it exists
    if [ -e /dev/coral ]; then
        echo "lxc.mount.entry: /dev/coral dev/coral none bind,optional,create=file" >> "$CONFIG_FILE"
    fi
    ```
  - Special thanks to **@Blaspt** for validating the persistent Coral USB passthrough and suggesting the use of `/dev/coral` symbolic link.


### Added
- **Persistent Coral USB Passthrough Support**  
  Added udev rule support for Coral USB devices to persistently map them as `/dev/coral`, enabling consistent passthrough across reboots. This path is automatically detected and mapped in the container configuration.

- **RSS Feed Integration**  
  Added support for generating an RSS feed for the changelog, allowing users to stay informed of updates through news clients.

- **Release Service Automation**  
  Implemented a new release management service to automate publishing and tagging of versions, starting with version **v1.1.2**.


## 2025-05-13

### Fixed

- **Startup Fix on Newer Virtuliser Versions**\
  Fixed an issue where some recent Virtuliser installations lacked the `/usr/local/bin` directory, causing errors when installing the execution menu. The script now creates the directory if it does not exist before downloading the main menu.\
  Thanks to **@danielmateos** for detecting and reporting this issue.

### Improved

- **Updated Lynis Installation Logic in Post-Install Settings**\
  The `install_lynis()` function was improved to always install the **latest version** of Lynis by cloning the official GitHub repository:
  ```
  https://github.com/CISOfy/lynis.git
  ```
  The installation process now ensures the latest version is always fetched and linked properly within the system path.

  Thanks to **@Kamunhas** for reporting this enhancement opportunity.

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

  Thanks to **@chesspeto** for pointing out this issue and helping refine the optimization.


## 2025-05-04

### Added
- **Interactive Help & Info Menu**  
  Added a new script called `Help and Info`, which provides an interactive command reference menu for Virtuliser VE through a dialog-based interface.  
  This tool offers users a quick way to browse and copy useful commands for managing and maintaining their Virtuliser server, all in one centralized location.

  ![Help and Info Menu](https://macrimi.github.io/vmenu/help/help-info-menu.png)

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
Introduced a new script that enables assigning a dedicated physical disk to a container (CT) in Virtuliser VE.
This utility lists available physical disks (excluding system and mounted disks), allows the user to select a container and one disk, and then formats or reuses the disk before mounting it inside the CT at a specified path.
It supports detection of existing filesystems and ensures permissions are properly configured. Ideal for use cases such as Samba, Nextcloud, or video surveillance containers.

### Improved  
- Visual Identification of Disks for Passthrough to VMs
Enhanced the disk detection logic in the Disk Passthrough to a VM script by including visual indicators and metadata.
Disks now display tags like ⚠ In use, ⚠ RAID, ⚠ LVM, or ⚠ ZFS, making it easier to recognize their current status at a glance. This helps prevent selection mistakes and improves clarity for the user.

## 2025-03-24  
### Improved  
- Improved the logic for detecting physical disks in the **Disk Passthrough to a VM** script. Previously, the script would display disks that were already mounted in the system on some setups. This update ensures that only unmounted disks are shown in Virtuliser, preventing confusion and potential conflicts.  

- This improvement ensures that disks already mounted or assigned to other VMs are excluded from the list of available disks, providing a more accurate and reliable selection process.

## [1.1.1] - 2025-03-21
### Improved
- Improved the logic of the post-install script to prevent overwriting or adding duplicate settings if similar settings are already configured by the user.
- Added a warning note to the documentation explaining that using different post-installation scripts is not recommended to avoid conflicts and duplicated settings.

### Added
- **Create Synology DSM VM**:  
  A new script that creates a VM to install Synology DSM. The script automates the process of downloading three different loaders with the option to use a custom loader provided by the user from the local storage options.  
  Additionally, it allows the use of both virtual and physical disks, which are automatically assigned by the script.  

  ![VM description](https://macrimi.github.io/vmenu/vm/synology/dsm_desc.png)
  
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
- Created a customizable post-install script for Virtuliser with 10 sections and 35 different selectable options.

## [1.0.7] - 2025-02-17
### Added
- Created a menu with essential scripts from the Virtuliser VE Helper-Scripts community.

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
- Added a function to **uninstall vmenu**.

## [1.0.1] - 2025-01-03
### Added
- Created a script to add **Coral TPU support in an LXC** for use in video surveillance programs.

## [1.0.0] - 2024-12-18
### Added
- Initial release of **vmenu**.
- Created a script to add **Coral TPU drivers** to Virtuliser.
