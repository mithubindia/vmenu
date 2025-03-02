import type { Metadata } from "next"
import { Plus } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Optional Settings",
  description:
    "Guide to Optional Settings in the ProxMenux post-install script for additional Proxmox VE features and optimizations.",
  openGraph: {
    title: "ProxMenux Post-Install: Optional Settings",
    description:
      "Guide to Optional Settings in the ProxMenux post-install script for additional Proxmox VE features and optimizations.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/optional",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/optional-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Optional Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Optional Settings",
    description:
      "Guide to Optional Settings in the ProxMenux post-install script for additional Proxmox VE features and optimizations.",
    images: ["https://macrimi.github.io/ProxMenux/optional-settings-image.png"],
  },
}

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
}

export default function OptionalSettingsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Plus className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Optional Settings</h1>
      </div>
      <p className="mb-4">
        The <strong>Optional Settings</strong> category provides additional features and optimizations that you can
        choose to apply to your Proxmox VE installation. These settings are not essential but can enhance your system's
        capabilities in specific scenarios.
      </p>
      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optional Features</h2>

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Add Latest Ceph Support
      </h3>
      <p className="mb-4">
        This option installs the latest Ceph storage system support for Proxmox VE. Ceph is a distributed storage system
        that provides high performance, reliability, and scalability.
      </p>
      <p className="mb-4">What it does:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Adds the Ceph repository to your system</li>
        <li>Updates package lists</li>
        <li>Installs Ceph packages using the 'pveceph install' command</li>
        <li>Verifies the installation</li>
      </ul>
      <p className="mb-4">
        How to use: After installation, you can configure and manage Ceph storage using the Proxmox VE web interface or
        command-line tools.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Add Ceph repository
echo "deb https://download.proxmox.com/debian/ceph-squid $(lsb_release -cs) no-subscription" > /etc/apt/sources.list.d/ceph-squid.list

# Update package lists
apt-get update

# Install Ceph
pveceph install

# Verify installation
pveceph status
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Apply AMD CPU Fixes
      </h3>
      <p className="mb-4">
        This option applies specific fixes for AMD EPYC and Ryzen CPUs to improve stability and compatibility.
      </p>
      <p className="mb-4">What it does:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Detects if an AMD EPYC or Ryzen CPU is present</li>
        <li>Applies kernel parameter 'idle=nomwait' to prevent random crashes</li>
        <li>Configures KVM to ignore certain MSRs (Model Specific Registers) for better Windows guest compatibility</li>
        <li>Installs the latest Proxmox VE kernel</li>
      </ul>
      <p className="mb-4">
        How to use: These fixes are applied automatically and require a system reboot to take effect.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Set kernel parameter
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="idle=nomwait /g' /etc/default/grub
update-grub

# Configure KVM
echo "options kvm ignore_msrs=Y" >> /etc/modprobe.d/kvm.conf
echo "options kvm report_ignored_msrs=N" >> /etc/modprobe.d/kvm.conf

# Install latest Proxmox VE kernel
apt-get install pve-kernel-$(uname -r | cut -d'-' -f1-2)
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Enable High Availability Services
      </h3>
      <p className="mb-4">
        This option enables High Availability (HA) services in Proxmox VE, allowing for automatic failover of VMs and
        containers in case of node failure.
      </p>
      <p className="mb-4">What it does:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Enables and starts the pve-ha-lrm (Local Resource Manager) service</li>
        <li>Enables and starts the pve-ha-crm (Cluster Resource Manager) service</li>
        <li>Enables and starts the corosync service for cluster communication</li>
      </ul>
      <p className="mb-4">
        How to use: After enabling these services, you can configure HA groups and resources in the Proxmox VE web
        interface.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
systemctl enable --now pve-ha-lrm pve-ha-crm corosync
      `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={4} />
        Install and Configure Fastfetch
      </h3>
      <p className="mb-4">
        This option installs and configures Fastfetch, a system information tool that displays system specs and a custom
        logo at login.
      </p>
      <p className="mb-4">What it does:</p>
      <ul className="list-disc pl-5 mb-4">
        <li>Downloads and installs Fastfetch</li>
        <li>
          Allows you to choose a custom logo (ProxMenux, Proxmox, Helper-Scripts, Home-Labs-Club, Proxmology, or a
          custom one)
        </li>
        <li>Configures Fastfetch to display "System optimised by ProxMenux"</li>
        <li>Sets up Fastfetch to run automatically at console login</li>
      </ul>
      <p className="mb-4">
        How to use: After installation, Fastfetch will run automatically when you log into the console, displaying
        system information and your chosen logo.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following commands:</p>
      <CopyableCode
        code={`
# Install Fastfetch
wget -qO /usr/local/bin/fastfetch "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64"
chmod +x /usr/local/bin/fastfetch

# Configure Fastfetch (logo selection and custom message are interactive)
fastfetch --gen-config

# Set Fastfetch to run at login
echo "clear && fastfetch" >> ~/.bashrc
      `}
      />

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          These optional features are applied only when specifically selected during the post-install process. Each
          feature can be individually chosen based on your specific needs and preferences.
        </p>
      </section>
    </div>
  )
}

