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
        <Steps.Step title="Install Common System Utilities" />
      </Steps>
      <section className="mb-8">
        <p className="mb-4">
          This optimization installs a set of common system utilities that are useful for system administration and
          troubleshooting.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Having these utilities pre-installed saves time when managing your
          Proxmox VE system. They provide essential tools for monitoring system performance, managing files, and
          troubleshooting issues, enhancing your ability to maintain and optimize your virtualization environment.
        </p>
        <h4 className="text-lg font-semibold mb-2">Utilities installed:</h4>
        <ul className="list-disc pl-5 mb-4">
          <li>
            <strong>axel</strong>: A light command-line download accelerator
          </li>
          <li>
            <strong>curl</strong>: A tool for transferring data using various protocols
          </li>
          <li>
            <strong>dialog</strong>: A tool for creating TUI interfaces
          </li>
          <li>
            <strong>dnsutils</strong>: DNS utilities including dig and nslookup
          </li>
          <li>
            <strong>dos2unix</strong>: Text file format converter
          </li>
          <li>
            <strong>gnupg-agent</strong>: GNU privacy guard - password agent
          </li>
          <li>
            <strong>grc</strong>: Generic colouriser for everything
          </li>
          <li>
            <strong>htop</strong>: An interactive process viewer
          </li>
          <li>
            <strong>btop</strong>: A resource monitor that shows usage and stats for processor, memory, disks, network
            and processes
          </li>
          <li>
            <strong>iftop</strong>: A tool to display bandwidth usage on an interface
          </li>
          <li>
            <strong>iotop</strong>: A tool to display I/O usage by processes
          </li>
          <li>
            <strong>iperf3</strong>: A tool for active measurements of the maximum achievable bandwidth on IP networks
          </li>
          <li>
            <strong>ipset</strong>: A tool to manage IP sets in the Linux kernel
          </li>
          <li>
            <strong>iptraf-ng</strong>: An interactive colorful IP LAN monitor
          </li>
          <li>
            <strong>mlocate</strong>: A tool to find files by name quickly
          </li>
          <li>
            <strong>msr-tools</strong>: Tools for accessing CPU model-specific registers
          </li>
          <li>
            <strong>nano</strong>: A small, friendly text editor
          </li>
          <li>
            <strong>net-tools</strong>: A collection of programs that form the base set of the NET-3 networking
            distribution for the Linux operating system
          </li>
          <li>
            <strong>omping</strong>: An open multicast ping tool
          </li>
          <li>
            <strong>software-properties-common</strong>: Provides an abstraction of the used apt repositories
          </li>
          <li>
            <strong>sshpass</strong>: A tool for non-interactive ssh password authentication
          </li>
          <li>
            <strong>tmux</strong>: A terminal multiplexer
          </li>
          <li>
            <strong>unzip</strong>: A tool for extracting and viewing files in .zip archives
          </li>
          <li>
            <strong>vim</strong> and <strong>vim-nox</strong>: A highly configurable text editor
          </li>
          <li>
            <strong>wget</strong>: A utility for non-interactive download of files from the Web
          </li>
          <li>
            <strong>whois</strong>: A client for the whois directory service
          </li>
          <li>
            <strong>zip</strong>: A compression and file packaging utility
          </li>
          <li>
            <strong>libguestfs-tools</strong>: A set of tools for accessing and modifying virtual machine disk images
          </li>
        </ul>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run:</h4>
        <CopyableCode
          code={`
# Update package lists
sudo apt-get update

# Install common system utilities
sudo apt-get install -y axel curl dialog dnsutils dos2unix gnupg-agent grc htop btop iftop iotop
sudo apt-get install -y iperf3 ipset iptraf-ng mlocate msr-tools nano net-tools omping
sudo apt-get install -y software-properties-common sshpass tmux unzip vim vim-nox wget whois zip
sudo apt-get install -y libguestfs-tools
        `}
        />
      </section>

      <Steps>
        <Steps.Step title="Skip Downloading Additional Languages" />
      </Steps>
      <section className="mb-8">
        <p className="mb-4">
          This optimization configures APT to skip downloading additional language packages, which can save disk space
          and speed up package operations.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> By skipping unnecessary language packages, you can reduce disk usage and
          improve the speed of package management operations. This is particularly useful in server environments where
          multiple language support is often not required.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run:</h4>
        <CopyableCode
          code={`
# Configure APT to skip downloading additional languages
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99-disable-translations
        `}
        />
      </section>

      <Steps>
        <Steps.Step title="Synchronize Time Automatically" />
      </Steps>
      <section className="mb-8">
        <p className="mb-4">
          This optimization configures the system to automatically synchronize its time, ensuring accurate timekeeping.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Accurate timekeeping is crucial for many system operations, log
          consistency, and proper functioning of time-sensitive applications. Automatic synchronization ensures your
          Proxmox VE system maintains the correct time without manual intervention.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run:</h4>
        <CopyableCode
          code={`
# Note: To set timezone automatically based on IP, you can use:
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
TIMEZONE=$(curl -s "https://ipapi.co/$IP/timezone")
sudo timedatectl set-timezone "$TIMEZONE"
        `}
        />
      </section>

      <Steps>
        <Steps.Step title="Update and Upgrade System" />
      </Steps>
      <section className="mb-8">
        <p className="mb-4">
          This optimization updates the system's package lists, upgrades installed packages, and configures Proxmox
          repositories. It also includes additional steps to properly set up Debian repositories and disable certain
          warnings.
        </p>
        <p className="mb-4">
          <strong>Why it's beneficial:</strong> Keeping your system up-to-date is essential for security, stability, and
          performance. This optimization ensures you have the latest patches and features, while also configuring the
          correct repositories for Proxmox VE, enabling access to necessary updates and tools.
        </p>
        <h4 className="text-lg font-semibold mb-2">To apply this optimization manually, run:</h4>
        <CopyableCode
          code={`
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
        `}
        />
      </section>

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

