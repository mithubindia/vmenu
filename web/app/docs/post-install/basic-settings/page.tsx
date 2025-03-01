import type { Metadata } from "next"
import { Settings } from 'lucide-react'
import CopyableCode from "@/components/CopyableCode"
import { Steps } from "@/components/ui/steps"

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
# Update package lists
sudo apt-get update

# Install common system utilities
sudo apt-get install -y axel curl dialog dnsutils dos2unix gnupg-agent grc htop btop iftop iotop
sudo apt-get install -y iperf3 ipset iptraf-ng mlocate msr-tools nano net-tools omping
sudo apt-get install -y software-properties-common sshpass tmux unzip vim vim-nox wget whois zip
sudo apt-get install -y libguestfs-tools
  `

  const skipLanguagesCode = `
# Configure APT to skip downloading additional languages
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99-disable-translations
  `

  const timeSyncCode = `
# Note: To set timezone automatically based on IP, you can use:
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
TIMEZONE=$(curl -s "https://ipapi.co/$IP/timezone")
sudo timedatectl set-timezone "$TIMEZONE"
  `

  const updateUpgradeCode = `
# Disable enterprise Proxmox repository
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
  sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Disable enterprise Proxmox Ceph repository
if [ -f /etc/apt/sources.list.d/ceph.list ]; then
  sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/ceph.list
fi

# Enable free public Proxmox repository
echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-public-repo.list

# Enable Proxmox testing repository
echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pvetest" | sudo tee /etc/apt/sources.list.d/pve-testing-repo.list

# Configure main Debian repositories
cat <<EOF | sudo tee /etc/apt/sources.list
deb http://deb.debian.org/debian $(lsb_release -cs) main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $(lsb_release -cs)-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $(lsb_release -cs)-security main contrib non-free non-free-firmware
EOF

# Disable non-free firmware warnings
echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' | sudo tee /etc/apt/apt.conf.d/no-bookworm-firmware.conf

# Update and upgrade
sudo apt-get update
sudo apt-get dist-upgrade -y

# Update PVE application manager
pveam update

# Install additional packages
sudo apt-get install -y zfsutils-linux proxmox-backup-restore-image chrony
  `

  export default function BasicSettingsPage() {
    const installUtilitiesCode = `
  # Update package lists
  sudo apt-get update
  
  # Install common system utilities
  sudo apt-get install -y axel curl dialog dnsutils dos2unix gnupg-agent grc htop btop iftop iotop
  sudo apt-get install -y iperf3 ipset iptraf-ng mlocate msr-tools nano net-tools omping
  sudo apt-get install -y software-properties-common sshpass tmux unzip vim vim-nox wget whois zip
  sudo apt-get install -y libguestfs-tools
    `
  
    const skipLanguagesCode = `
  # Configure APT to skip downloading additional languages
  echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99-disable-translations
    `
  
    const timeSyncCode = `
  # Note: To set timezone automatically based on IP, you can use:
  IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
  TIMEZONE=$(curl -s "https://ipapi.co/$IP/timezone")
  sudo timedatectl set-timezone "$TIMEZONE"
    `
  
    const updateUpgradeCode = `
  # Disable enterprise Proxmox repository
  if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
  fi
  
  # Disable enterprise Proxmox Ceph repository
  if [ -f /etc/apt/sources.list.d/ceph.list ]; then
    sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/ceph.list
  fi
  
  # Enable free public Proxmox repository
  echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-public-repo.list
  
  # Enable Proxmox testing repository
  echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pvetest" | sudo tee /etc/apt/sources.list.d/pve-testing-repo.list
  
  # Configure main Debian repositories
  cat <<EOF | sudo tee /etc/apt/sources.list
  deb http://deb.debian.org/debian $(lsb_release -cs) main contrib non-free non-free-firmware
  deb http://deb.debian.org/debian $(lsb_release -cs)-updates main contrib non-free non-free-firmware
  deb http://security.debian.org/debian-security $(lsb_release -cs)-security main contrib non-free non-free-firmware
  EOF
  
  # Disable non-free firmware warnings
  echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' | sudo tee /etc/apt/apt.conf.d/no-bookworm-firmware.conf
  
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
          The <strong>Basic Settings</strong> category focuses on foundational configurations for your Proxmox VE
          installation, including installing essential utilities, adding repositories, managing packages, and keeping the
          system up to date.
        </p>
  
        <h2 className="text-2xl font-semibold mt-8 mb-4">Available Optimizations</h2>
  
        <Steps>
          <Steps.Step title="Install Common System Utilities">
            <p>
              This step installs a set of common system utilities useful for system administration and troubleshooting.
            </p>
            <h4 className="text-lg font-semibold mt-4 mb-2">Utilities installed:</h4>
            <ul className="list-disc pl-5 mb-4">
              <li>
                <strong>axel</strong>: A light command-line download accelerator
              </li>
              <li>
                <strong>curl</strong>: A tool for transferring data using various protocols
              </li>
              <li>
                <strong>dialog</strong>: A full-screen dialog library
              </li>
              <li>
                <strong>dnsutils</strong>: Various utilities for DNS lookups
              </li>
              <li>
                <strong>dos2unix</strong>: Converts DOS text files to Unix format
              </li>
              <li>
                <strong>gnupg-agent</strong>: A helper application for GnuPG
              </li>
              <li>
                <strong>grc</strong>: Colorizes command output
              </li>
              <li>
                <strong>htop</strong>: An interactive process viewer
              </li>
              <li>
                <strong>btop</strong>: A system monitor
              </li>
              <li>
                <strong>iftop</strong>: A network monitor
              </li>
              <li>
                <strong>iotop</strong>: A disk I/O monitor
              </li>
              <li>
                <strong>iperf3</strong>: A network bandwidth measurement tool
              </li>
              <li>
                <strong>ipset</strong>: A powerful tool for managing IP sets
              </li>
              <li>
                <strong>iptraf-ng</strong>: A network traffic monitor
              </li>
              <li>
                <strong>mlocate</strong>: A fast file locator
              </li>
              <li>
                <strong>msr-tools</strong>: Tools for managing MSR registers
              </li>
              <li>
                <strong>nano</strong>: A simple text editor
              </li>
              <li>
                <strong>net-tools</strong>: Various network utilities
              </li>
              <li>
                <strong>mping</strong>: A multi-ping tool
              </li>
              <li>
                <strong>software-properties-common</strong>: Common tools for managing software repositories
              </li>
              <li>
                <strong>sshpass</strong>: A tool for automating SSH password entry
              </li>
              <li>
                <strong>tmux</strong>: A terminal multiplexer
              </li>
              <li>
                <strong>unzip</strong>: A tool for extracting zip archives
              </li>
              <li>
                <strong>vim</strong>: A powerful text editor
              </li>
              <li>
                <strong>vim-nox</strong>: Vim without X11 dependencies
              </li>
              <li>
                <strong>wget</strong>: A command-line download utility
              </li>
              <li>
                <strong>whois</strong>: A tool for querying WHOIS databases
              </li>
              <li>
                <strong>zip</strong>: A tool for creating zip archives
              </li>
              <li>
                <strong>libguestfs-tools</strong>: Tools for managing guest virtual machines
              </li>
            </ul>
            <CopyableCode code={installUtilitiesCode} />
          </Steps.Step>
          <Steps.Step title="Skip Downloading Additional Languages">
            <p>
              This optimization configures APT to skip downloading additional language packages, saving disk space and
              speeding up package operations.
            </p>
            <CopyableCode code={skipLanguagesCode} />
          </Steps.Step>
          <Steps.Step title="Synchronize Time Automatically">
            <p>This step configures the system to automatically synchronize its time, ensuring accurate timekeeping.</p>
            <CopyableCode code={timeSyncCode} />
          </Steps.Step>
          <Steps.Step title="Update and Upgrade System">
            <p>
              This optimization updates the system's package lists, upgrades installed packages, and configures Proxmox
              repositories.
            </p>
            <CopyableCode code={updateUpgradeCode} />
          </Steps.Step>
        </Steps>
  
        <section className="mt-12 p-4 bg-blue-100 rounded-md">
          <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
          <p>
            All of these optimizations are automatically applied when selected in the Basic Settings section. This
            automation ensures that these beneficial settings are applied consistently and correctly, saving time and
            reducing the potential for human error during manual configuration.
          </p>
        </section>
      </div>
    )
  }