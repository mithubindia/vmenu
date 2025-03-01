import type { Metadata } from "next"
import { Settings } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Basic Settings",
  description:
    "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  openGraph: {
    title: "ProxMenux Post-Install: Basic Settings",
    description:
      "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    type: "article",
    url: "https://macrimi.github.io/ProxMenux/docs/post-install/basic-settings",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/basic-settings-image.png",
        width: 1200,
        height: 630,
        alt: "ProxMenux Post-Install Basic Settings",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux Post-Install: Basic Settings",
    description:
      "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
    images: ["https://macrimi.github.io/ProxMenux/basic-settings-image.png"],
  },
}

export default function BasicSettingsPage() {
  const installUtilitiesCode = `
sudo apt-get update
sudo apt-get install -y axel curl dialog dnsutils dos2unix gnupg-agent grc htop btop iftop iotop \\
    iperf3 ipset iptraf-ng mlocate msr-tools nano net-tools omping \\
    software-properties-common sshpass tmux unzip vim vim-nox wget whois zip \\
    libguestfs-tools
  `

  const skipLanguagesCode = `
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99-disable-translations
  `

  const timeSyncCode = `
# To set timezone automatically based on IP, you would need to run:
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
TIMEZONE=$(curl -s "https://ipapi.co/$IP/timezone")
sudo timedatectl set-timezone "$TIMEZONE"
  `

  const updateUpgradeCode = `
# Disable enterprise repos
sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/ceph.list

# Enable free public repo
echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-public-repo.list

# Update and upgrade
sudo apt-get update
sudo apt-get dist-upgrade -y

# Update PVE application manager
pveam update

# Install additional packages
sudo apt-get install -y zfsutils-linux proxmox-backup-restore-image chrony
  `

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <Settings className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold">Basic Settings</h1>
      </div>
      <p className="mb-4">
        The Basic Settings category in the customizable_post_install.sh script covers fundamental configurations for
        your Proxmox VE installation. These settings lay the groundwork for a well-optimized system.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">1. Install Common System Utilities</h3>
        <p className="mb-4">
          This optimization installs a set of common system utilities that are useful for system administration and
          troubleshooting.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Having these utilities pre-installed saves time when managing your
          Proxmox VE system. They provide essential tools for monitoring system performance, managing files, and
          troubleshooting issues, enhancing your ability to maintain and optimize your virtualization environment.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{installUtilitiesCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">2. Skip Downloading Additional Languages</h3>
        <p className="mb-4">
          This optimization configures APT to skip downloading additional language packages, which can save disk space
          and speed up package operations.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> By skipping unnecessary language packages, you can reduce disk usage and
          improve the speed of package management operations. This is particularly useful in server environments where
          multiple language support is often not required.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{skipLanguagesCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">3. Synchronize Time Automatically</h3>
        <p className="mb-4">
          This optimization configures the system to automatically synchronize its time, ensuring accurate timekeeping.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Accurate timekeeping is crucial for many system operations, log
          consistency, and proper functioning of time-sensitive applications. Automatic synchronization ensures your
          Proxmox VE system maintains the correct time without manual intervention.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{timeSyncCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">4. Update and Upgrade System</h3>
        <p className="mb-4">
          This optimization updates the system's package lists, upgrades installed packages, and configures Proxmox
          repositories.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Keeping your system up-to-date is essential for security, stability, and
          performance. This optimization ensures you have the latest patches and features, while also configuring the
          correct repositories for Proxmox VE, enabling access to necessary updates and tools.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, you would run:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{updateUpgradeCode}</code>
        </pre>
      </section>

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Basic Settings section of the
          customizable_post_install.sh script. This automation ensures that these beneficial settings are applied
          consistently and correctly.
        </p>
      </section>
    </div>
  )
}

