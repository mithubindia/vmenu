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
    <div className="container mx-auto px-4 py-8 max-w-screen-lg">
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
        {/* Step 1 */}
        <Steps.Step title="Install Common System Utilities">
          <p>This optimization installs a set of common system utilities that are useful for system administration and troubleshooting.</p>
          <p><strong>Why it's beneficial:</strong> Having these utilities pre-installed saves time when managing your Proxmox VE system.</p>
          <h4 className="text-lg font-semibold mb-2">Utilities installed:</h4>
          <ul className="list-disc pl-5 mb-4">
            <li><strong>axel</strong>: A light command-line download accelerator</li>
            <li><strong>curl</strong>: A tool for transferring data using various protocols</li>
            <li><strong>dnsutils</strong>: DNS utilities including dig and nslookup</li>
            <li><strong>htop</strong>: An interactive process viewer</li>
            <li><strong>iperf3</strong>: A tool for network performance testing</li>
          </ul>
          <div className="max-w-full overflow-x-auto">
            <CopyableCode code={`sudo apt-get install -y axel curl dnsutils htop iperf3`} />
          </div>
        </Steps.Step>

        {/* Step 2 */}
        <Steps.Step title="Skip Downloading Additional Languages">
          <p>This optimization configures APT to skip downloading additional language packages, which can save disk space.</p>
          <p><strong>Why it's beneficial:</strong> Reduces disk usage and improves the speed of package management.</p>
          <div className="max-w-full overflow-x-auto">
            <CopyableCode code={`echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99-disable-translations`} />
          </div>
        </Steps.Step>

        {/* Step 3 */}
        <Steps.Step title="Synchronize Time Automatically">
          <p>This optimization configures the system to automatically synchronize its time, ensuring accurate timekeeping.</p>
          <p><strong>Why it's beneficial:</strong> Ensures accurate system logs and application timestamps.</p>
          <div className="max-w-full overflow-x-auto">
            <CopyableCode code={`sudo timedatectl set-timezone "UTC"`} />
          </div>
        </Steps.Step>

        {/* Step 4 */}
        <Steps.Step title="Update and Upgrade System">
          <p>This optimization updates the system's package lists, upgrades installed packages, and configures Proxmox repositories.</p>
          <p><strong>Why it's beneficial:</strong> Ensures security patches and stability improvements.</p>
          <div className="max-w-full overflow-x-auto">
            <CopyableCode code={`
# Disable enterprise Proxmox repository
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
  sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Enable free public Proxmox repository
echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-public-repo.list

# Update and upgrade system
sudo apt-get update && sudo apt-get dist-upgrade -y
            `} />
          </div>
        </Steps.Step>
      </Steps>

      <section className="mt-12 p-4 bg-blue-100 rounded-md">
        <h2 className="text-xl font-semibold mb-2">Automatic Application</h2>
        <p>
          All of these optimizations are automatically applied when selected in the Basic Settings section. 
          This automation ensures that these beneficial settings are applied consistently and correctly, saving time and reducing human error.
        </p>
      </section>
    </div>
  )
}
