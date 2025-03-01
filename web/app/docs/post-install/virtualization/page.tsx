import type { Metadata } from "next"
import { Box } from "lucide-react"

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
# Enable IOMMU for Intel or AMD CPU
# For Intel:
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ intel_iommu=on iommu=pt"/' /etc/default/grub
# For AMD:
# sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ amd_iommu=on iommu=pt"/' /etc/default/grub

# Configure VFIO modules
echo "vfio" >> /etc/modules
echo "vfio_iommu_type1" >> /etc/modules
echo "vfio_pci" >> /etc/modules
echo "vfio_virqfd" >> /etc/modules

# Blacklist conflicting drivers
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf

# Update GRUB and initramfs
update-grub
update-initramfs -u -k all
  `

  const installGuestAgentCode = `
# Detect virtualization environment
VIRT_ENV=$(systemd-detect-virt)

# Install appropriate guest agent
case $VIRT_ENV in
  kvm)
    apt-get install -y qemu-guest-agent
    ;;
  vmware)
    apt-get install -y open-vm-tools
    ;;
  oracle)
    apt-get install -y virtualbox-guest-utils
    ;;
  *)
    echo "No specific guest agent needed or virtualization not detected."
    ;;
esac
  `

  const configureKsmtunedCode = `
# Install KSM control daemon
apt-get install -y ksm-control-daemon

# Configure KSM based on system RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ $RAM_GB -le 16 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=50/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=80/' /etc/ksmtuned.conf
elif [ $RAM_GB -le 32 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=40/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=60/' /etc/ksmtuned.conf
elif [ $RAM_GB -le 64 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=30/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=40/' /etc/ksmtuned.conf
elif [ $RAM_GB -le 128 ]; then
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=20/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=20/' /etc/ksmtuned.conf
else
  sed -i 's/KSM_THRES_COEF=.*/KSM_THRES_COEF=10/' /etc/ksmtuned.conf
  sed -i 's/KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=10/' /etc/ksmtuned.conf
fi

# Enable ksmtuned service
systemctl enable ksmtuned
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
          scenarios.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{enableVfioIommuCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">2. Install Relevant Guest Agent</h3>
        <p className="mb-4">
          This optimization detects the virtualization environment and installs the appropriate guest agent for improved
          integration between the host and guest systems.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Guest agents improve communication between the host and guest systems,
          enabling features like graceful shutdown, file sharing, and better performance monitoring. This ensures
          smoother operation and management of virtual machines.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{installGuestAgentCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">3. Configure KSM Control Daemon</h3>
        <p className="mb-4">
          This optimization installs and configures the KSM (Kernel Samepage Merging) control daemon, which helps
          optimize memory usage in virtualized environments.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> KSM allows the kernel to share identical memory pages between multiple
          virtual machines, reducing overall memory usage. This can lead to better resource utilization, especially in
          environments with many similar virtual machines.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{configureKsmtunedCode}</code>
        </pre>
      </section>

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Virtualization section of the
          customizable_post_install.sh script. This automation ensures that these beneficial settings are applied
          consistently and correctly.
        </p>
      </section>
    </div>
  )
}

