import type { Metadata } from "next"
import { Settings } from "lucide-react"
import CopyableCode from "@/components/CopyableCode"

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

function StepNumber({ number }: { number: number }) {
  return (
    <div className="inline-flex items-center justify-center w-8 h-8 mr-3 text-white bg-blue-500 rounded-full">
      <span className="text-sm font-bold">{number}</span>
    </div>
  )
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

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={1} />
        Install Common System Utilities
      </h3>
      <p className="mb-4">
        This optimization installs a set of common system utilities that are useful for system administration and
        troubleshooting.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Having these utilities pre-installed saves time when managing your Proxmox
        VE system. They provide essential tools for monitoring system performance, managing files, and troubleshooting
        issues, enhancing your ability to maintain and optimize your virtualization environment.
      </p>
      <h4 className="text-lg font-semibold mb-2">Utilities installed:</h4>
      <ul className="list-disc pl-5 mb-4 space-y-8">

      <li>
        <strong>axel</strong>: A light command-line download accelerator
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">axel -n 10 http://example.com/largefile.zip</code>
      </li>
      <li>
        <strong>curl</strong>: A tool for transferring data using various protocols
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">curl -O http://example.com/file.txt</code>
      </li>
      <li>
        <strong>dialog</strong>: A tool for creating TUI interfaces
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">dialog --title "Hello" --msgbox "Hello, World!" 10 20</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/dialog.png"
          alt="Dialog Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
      <li>
        <strong>dnsutils</strong>: DNS utilities including dig and nslookup
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">dig example.com</code>
        <code className="block bg-gray-100 p-2 rounded mt-2">nslookup example.com</code>
      </li>
      <li>
        <strong>dos2unix</strong>: Text file format converter
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">dos2unix file.txt</code>
      </li>
      <li>
        <strong>gnupg-agent</strong>: GNU privacy guard - password agent
        <p className="mt-2">This runs in the background. To start it:</p>
        <code className="block bg-gray-100 p-2 rounded">gpg-agent --daemon</code>
      </li>
      <li>
        <strong>grc</strong>: Generic colouriser for everything
        <p className="mt-2">Example usage (colorize ping output):</p>
        <code className="block bg-gray-100 p-2 rounded">grc ping example.com</code>
      </li>
      <li>
        <strong>htop</strong>: An interactive process viewer
        <p className="mt-2">To start htop, simply type:</p>
        <code className="block bg-gray-100 p-2 rounded">htop</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/htop.png"
          alt="htop Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
      <li>
        <strong>btop</strong>: A resource monitor that shows usage and stats for processor, memory, disks, network and processes
        <p className="mt-2">To start btop, type:</p>
        <code className="block bg-gray-100 p-2 rounded">btop</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/btop.png"
          alt="btop Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
     <li>
        <strong>iftop</strong>: A tool to display bandwidth usage on an interface
        <p className="mt-2">To start iftop (requires root):</p>
        <code className="block bg-gray-100 p-2 rounded">sudo iftop</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/iftop.png"
          alt="iftop Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
      <li>
        <strong>iotop</strong>: A tool to display I/O usage by processes
        <p className="mt-2">To start iotop (requires root):</p>
        <code className="block bg-gray-100 p-2 rounded">sudo iotop</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/iotop.png"
          alt="iotop Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
      <li>>
        <strong>iperf3</strong>: A tool for active measurements of the maximum achievable bandwidth on IP networks
        <p className="mt-2">Example usage (server mode):</p>
        <code className="block bg-gray-100 p-2 rounded">iperf3 -s</code>
        <p className="mt-2">Example usage (client mode):</p>
        <code className="block bg-gray-100 p-2 rounded">iperf3 -c server_ip</code>
      </li>
      <li>
        <strong>ipset</strong>: A tool to manage IP sets in the Linux kernel
        <p className="mt-2">Example usage (create a new set):</p>
        <code className="block bg-gray-100 p-2 rounded">ipset create myset hash:ip</code>
      </li>
      <li>
        <strong>iptraf-ng</strong>: An interactive colorful IP LAN monitor
        <p className="mt-2">To start iptraf-ng:</p>
        <code className="block bg-gray-100 p-2 rounded">sudo iptraf-ng</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/iptraf-ng.png"
          alt="iptraf-ng Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
     <li>
        <strong>mlocate</strong>: A tool to find files by name quickly
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">locate filename</code>
      </li>
      <li>
        <strong>msr-tools</strong>: Tools for accessing CPU model-specific registers
        <p className="mt-2">Example usage (read MSR):</p>
        <code className="block bg-gray-100 p-2 rounded">sudo rdmsr 0x1a0</code>
      </li>
      <li>
        <strong>nano</strong>: A small, friendly text editor
        <p className="mt-2">To open a file with nano:</p>
        <code className="block bg-gray-100 p-2 rounded">nano filename.txt</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/nano.png"
          alt="nano Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
     <li>
        <strong>net-tools</strong>: A collection of programs that form the base set of the NET-3 networking distribution for the Linux operating system
        <p className="mt-2">Example usage (show network interfaces):</p>
        <code className="block bg-gray-100 p-2 rounded">ifconfig</code>
      </li>
      <li>
        <strong>omping</strong>: An open multicast ping tool
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">omping 239.255.255.250</code>
      </li>
      <li>
        <strong>software-properties-common</strong>: Provides an abstraction of the used apt repositories
        <p className="mt-2">This package is typically used by other tools and doesn't have a direct command-line interface.</p>
      </li>
      <li>
        <strong>sshpass</strong>: A tool for non-interactive ssh password authentication
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">sshpass -p 'password' ssh user@hostname</code>
      </li>
      <li>
        <strong>tmux</strong>: A terminal multiplexer
        <p className="mt-2">To start a new tmux session:</p>
        <code className="block bg-gray-100 p-2 rounded">tmux</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/tmux.png"
          alt="tmux Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
      <li>
        <strong>unzip</strong>: A tool for extracting and viewing files in .zip archives
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">unzip file.zip</code>
      </li>
      <li>
        <strong>vim</strong> and <strong>vim-nox</strong>: A highly configurable text editor
        <p className="mt-2">To open a file with vim:</p>
        <code className="block bg-gray-100 p-2 rounded">vim filename.txt</code>
        <img
          src="https://macrimi.github.io/ProxMenux/basic/vim.png"
          alt="vim Example"
          className="mt-2 rounded shadow-lg"
        />
      </li>
      <li>
        <strong>wget</strong>: A utility for non-interactive download of files from the Web
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">wget http://example.com/file.zip</code>
      </li>
      <li>
        <strong>whois</strong>: A client for the whois directory service
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">whois example.com</code>
      </li>
      <li>
        <strong>zip</strong>: A compression and file packaging utility
        <p className="mt-2">Example usage:</p>
        <code className="block bg-gray-100 p-2 rounded">zip archive.zip file1 file2 file3</code>
      </li>
      <li>
        <strong>libguestfs-tools</strong>: A set of tools for accessing and modifying virtual machine disk images
        <p className="mt-2">Example usage (list files in a VM disk image):</p>
        <code className="block bg-gray-100 p-2 rounded">guestfish -a disk.img -m /dev/sda1 ls /</code>
      </li>

      </ul>
      <p className="text-lg mb-2">All these utilities are installed automatically when you run this command:</p>
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

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={2} />
        Skip Downloading Additional Languages
      </h3>
      <p className="mb-4">
        This optimization configures APT to skip downloading additional language packages, which can save disk space and
        speed up package operations.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        By skipping unnecessary language packages, you can reduce disk usage and
        improve the speed of package management operations. This is particularly useful in server environments where
        multiple language support is often not required.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following command:</p>
      <CopyableCode
        code={`
# Configure APT to skip downloading additional languages
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99-disable-translations
        `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={3} />
        Synchronize Time Automatically
      </h3>
      <p className="mb-4">
        This optimization configures the system to automatically synchronize its time, ensuring accurate timekeeping.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Accurate timekeeping is crucial for many system operations, log
        consistency, and proper functioning of time-sensitive applications. Automatic synchronization ensures your
        Proxmox VE system maintains the correct time without manual intervention.
      </p>
      <p className="text-lg mb-2">This adjustment automates the following command:</p>
      <CopyableCode
        code={`
# Note: To set timezone automatically based on IP, you can use:
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
TIMEZONE=$(curl -s "https://ipapi.co/$IP/timezone")
sudo timedatectl set-timezone "$TIMEZONE"
        `}
      />

      <h3 className="text-xl font-semibold mt-16 mb-4 flex items-center">
        <StepNumber number={4} />
        Update and Upgrade System
      </h3>
      <p className="mb-4">
        This optimization updates the system's package lists, upgrades installed packages, and configures Proxmox
        repositories. It also includes additional steps to properly set up Debian repositories and disable certain
        warnings.
      </p>
      <p className="mb-4">
      <strong className="block">Why it's beneficial:</strong>
        Keeping your system up-to-date is essential for security, stability, and
        performance. This optimization ensures you have the latest patches and features, while also configuring the
        correct repositories for Proxmox VE, enabling access to necessary updates and tools.
      </p>
      <h4 className="text-lg font-semibold mb-2">Repository changes:</h4>
      <ul className="list-disc pl-5 mb-4 space-y-2">
        <li>
          <strong>Disabled:</strong> Enterprise Proxmox repository (pve-enterprise.list) - This repository is for users
          with a paid subscription.
        </li>
        <li>
          <strong>Disabled:</strong> Enterprise Proxmox Ceph repository (ceph.list) - This repository is for enterprise
          Ceph storage solutions.
        </li>
        <li>
          <strong>Added:</strong> Free public Proxmox repository (pve-public-repo.list) - This provides access to free
          Proxmox VE updates and packages.
        </li>
        <li>
          <strong>Added:</strong> Proxmox testing repository (pve-testing-repo.list) - This repository contains the
          latest, potentially unstable updates for testing purposes.
        </li>
        <li>
          <strong>Configured:</strong> Main Debian repositories - These provide access to the core Debian packages and
          security updates.
        </li>
      </ul>
      <p className="text-lg mb-2">This adjustment automates the following command:</p>
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

