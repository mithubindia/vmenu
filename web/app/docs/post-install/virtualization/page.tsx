import type { Metadata } from "next"
import { Box } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Virtualization Settings",
  description:
    "Detailed guide to the Virtualization Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: Virtualization Settings",
    description:
      "Detailed guide to the Virtualization Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/virtualization",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/virtualization-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Virtualization Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Virtualization Settings",
    description:
      "Detailed guide to the Virtualization Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    images: ["https://macrimi.github.io/ProxMenux/virtualization-settings-image.png"],
  },
}

export default function VirtualizationSettingsPage() {
  const enableVfioIommuCode = `
#!/bin/bash

# Enable IOMMU for Intel or AMD CPU
if grep -q GenuineIntel /proc/cpuinfo; then
  sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ intel_iommu=on iommu=pt"/' /etc/default/grub
elif grep -q AuthenticAMD /proc/cpuinfo; then
  sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ amd_iommu=on iommu=pt"/' /etc/default/grub
else
  echo "Unknown CPU type. IOMMU might not be properly enabled."
  exit 1
fi

# Configure VFIO modules
echo "vfio" >> /etc/modules
echo "vfio_iommu_type1" >> /etc/modules
echo "vfio_pci" >> /etc/modules
echo "vfio_virqfd" >> /etc/modules

# Blacklist conflicting drivers
cat <<EOF >> /etc/modprobe.d/blacklist.conf
blacklist nouveau
blacklist nvidia
blacklist radeon
blacklist amdgpu
EOF

# Update GRUB and initramfs
update-grub
update-initramfs -u -k all

echo "VFIO IOMMU support has been enabled. Please reboot your system for changes to take effect."
  `

  const installGuestAgentCode = `
#!/bin/bash

# Detect virtualization environment
VIRT_ENV=$(systemd-detect-virt)

# Install appropriate guest agent
case $VIRT_ENV in
  kvm)
    apt-get update
    apt-get install -y qemu-guest-agent
    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent
    echo "QEMU Guest Agent installed and started."
    ;;
  vmware)
    apt-get update
    apt-get install -y open-vm-tools
    systemctl enable open-vm-tools
    systemctl start open-vm-tools
    echo "Open VM Tools installed and started."
    ;;
  oracle)
    apt-get update
    apt-get install -y virtualbox-guest-utils
    systemctl enable vboxadd
    systemctl start vboxadd
    echo "VirtualBox Guest Additions installed and started."
    ;;
  *)
    echo "No specific guest agent needed or virtualization not detected."
    ;;
esac

echo "Guest agent installation process completed."
  `

  const configureKsmtunedCode = `
#!/bin/bash

# Install KSM control daemon
apt-get update
apt-get install -y ksm-control-daemon

# Configure KSM based on system RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ $RAM_GB -le 16 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=50/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=80/' /etc/ksmtuned.conf
  echo "RAM <= 16GB: Setting KSM to start at 50% full"
elif [ $RAM_GB -le 32 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=40/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=60/' /etc/ksmtuned.conf
  echo "RAM <= 32GB: Setting KSM to start at 60% full"
elif [ $RAM_GB -le 64 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=30/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=40/' /etc/ksmtuned.conf
  echo "RAM <= 64GB: Setting KSM to start at 70% full"
elif [ $RAM_GB -le 128 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=20/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=20/' /etc/ksmtuned.conf
  echo "RAM <= 128GB: Setting KSM to start at 80% full"
else
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=10/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=10/' /etc/ksmtuned.conf
  echo "RAM > 128GB: Setting KSM to start at 90% full"
fi

# Enable ksmtuned service
systemctl enable ksmtuned
systemctl start ksmtuned

echo "KSM configuration completed and service started."
  `

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Box className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Virtualization Settings</h1>
      </div>
      <p className="mb-4">
        The Virtualization Settings category in the customizable_post_install.sh script focuses on optimizing your
        Proxmox VE installation for better virtualization performance and compatibility.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">1. Enable VFIO IOMMU Support</h3>
        <p className="mb-4">
          This optimization enables IOMMU (Input-Output Memory Management Unit) and configures VFIO (Virtual Function
          I/O) for PCI passthrough, allowing direct assignment of PCI devices to virtual machines.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> IOMMU and VFIO support enables near-native performance for PCI devices
          (like GPUs or network cards) in virtual machines, which is crucial for high-performance virtualization
          scenarios. This allows for:
        </p>
        <ul className="list-disc pl-5 mb-4">
          <li>Direct access to hardware from within VMs, improving performance</li>
          <li>Better isolation between host and guest systems</li>
          <li>Support for advanced features like GPU passthrough for gaming or compute workloads</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">
          To apply this optimization manually, save the following script and run it with root privileges:
        </h4>
        <CopyableCode code={enableVfioIommuCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">2. Install Relevant Guest Agent</h3>
        <p className="mb-4">
          This optimization detects the virtualization environment and installs the appropriate guest agent for improved
          integration between the host and guest systems.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Guest agents improve communication between the host and guest systems,
          enabling features like:
        </p>
        <ul className="list-disc pl-5 mb-4">
          <li>Graceful shutdown of virtual machines</li>
          <li>File sharing between host and guest</li>
          <li>Better performance monitoring and resource allocation</li>
          <li>Improved time synchronization</li>
          <li>Enhanced mouse pointer integration</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">
          To apply this optimization manually, save the following script and run it with root privileges:
        </h4>
        <CopyableCode code={installGuestAgentCode} />
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">3. Configure KSM Control Daemon</h3>
        <p className="mb-4">
          This optimization installs and configures the KSM (Kernel Samepage Merging) control daemon, which helps
          optimize memory usage in virtualized environments.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> KSM allows the kernel to share identical memory pages between multiple
          virtual machines, providing several advantages:
        </p>
        <ul className="list-disc pl-5 mb-4">
          <li>Reduced overall memory usage, allowing for higher VM density</li>
          <li>Improved performance in environments with many similar VMs</li>
          <li>Dynamic adjustment of KSM aggressiveness based on system memory pressure</li>
          <li>Potential for running more VMs on the same hardware</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">
          To apply this optimization manually, save the following script and run it with root privileges:
        </h4>
        <CopyableCode code={configureKsmtunedCode} />
      </section>

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Virtualization section of the
          customizable_post_install.sh script. This automation ensures that these beneficial settings are applied
          consistently and correctly, saving time and reducing the potential for human error during manual
          configuration.
        </p>
      </section>
    </div>
  )
}

