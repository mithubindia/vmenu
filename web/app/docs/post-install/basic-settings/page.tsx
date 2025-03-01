import type { Metadata } from "next"
import { Settings } from "lucide-react"

export const metadata: Metadata = {
  title: "ProxMenux Post-Install: Basic Settings",
  description:
    "Detailed guide to the Basic Settings category in the ProxMenux post-install script for Proxmox VE optimization.",
  // ... (rest of the metadata remains the same)
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
# Set timezone (replace 'America/New_York' with your timezone)
sudo timedatectl set-timezone America/New_York

# Enable automatic time synchronization
sudo timedatectl set-ntp true
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
        <h4 className="text-lg font-semibold mb-2">What it does:</h4>
        <ul className="list-disc pl-5 mb-4">
          <li>Installs packages like curl, htop, iftop, nano, vim, and more</li>
          <li>Checks which packages are already installed to avoid unnecessary installations</li>
          <li>Provides a progress bar during the installation process</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">Manual commands:</h4>
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
        <h4 className="text-lg font-semibold mb-2">What it does:</h4>
        <ul className="list-disc pl-5 mb-4">
          <li>Creates or modifies the APT configuration file to skip language downloads</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">Manual commands:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{skipLanguagesCode}</code>
        </pre>
      </section>

      <section className="mb-8">
        <h3 className="text-xl font-semibold mb-2">3. Synchronize Time Automatically</h3>
        <p className="mb-4">
          This optimization configures the system to automatically synchronize its time, ensuring accurate timekeeping.
        </p>
        <h4 className="text-lg font-semibold mb-2">What it does:</h4>
        <ul className="list-disc pl-5 mb-4">
          <li>Attempts to set the timezone automatically based on the system's IP address</li>
          <li>Enables automatic time synchronization using systemd's timesyncd</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">Manual commands:</h4>
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
        <h4 className="text-lg font-semibold mb-2">What it does:</h4>
        <ul className="list-disc pl-5 mb-4">
          <li>Disables enterprise Proxmox repositories</li>
          <li>Enables free public Proxmox repository</li>
          <li>Configures main Debian repositories</li>
          <li>Updates package lists and performs a system upgrade</li>
          <li>Updates PVE application manager</li>
          <li>Installs additional Proxmox packages</li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">Manual commands:</h4>
        <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto">
          <code>{updateUpgradeCode}</code>
        </pre>
      </section>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Usage</h2>
      <p className="mb-4">
        When running the customizable_post_install.sh script, you'll be prompted to choose which Basic Settings
        optimizations to apply. You can select all or pick specific ones based on your needs.
      </p>
      <p>
        For detailed information on each optimization and its impact, refer to the script comments or consult the
        ProxMenux documentation.
      </p>
    </div>
  )
}

